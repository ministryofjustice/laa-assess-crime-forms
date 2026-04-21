# Copilot instructions for `laa-assess-crime-forms`

## Build, test, and lint commands

### Setup and data prep
- Install dependencies: `brew bundle && bundle install && yarn install --frozen-lockfile`
- Prepare DBs: `bin/rails db:prepare && RAILS_ENV=test bin/rails db:prepare`
- Prepare flatware test DB shards: `RAILS_ENV=test bundle exec flatware fan rake db:test:prepare`

### Build assets
- JavaScript bundle: `yarn build`
- CSS bundle: `yarn build:css`
- Full Rails asset compile (used in local setup docs): `rails assets:precompile`

### Ruby tests (RSpec + flatware)
- Full suite (excluding accessibility specs by default): `bundle exec flatware rspec`
- Include accessibility specs: `INCLUDE_ACCESSIBILITY_SPECS=1 bundle exec flatware rspec`
- Run a single spec file: `bundle exec flatware rspec spec/path/to/file_spec.rb`
- Run one example by line: `bundle exec flatware rspec spec/path/to/file_spec.rb:123`
- Run only system specs: `bundle exec flatware rspec --tag type:system`
- Run non-system specs: `bundle exec flatware rspec --tag ~type:system`

### JavaScript tests
- Run Jest tests: `yarn unit-test`
- Run a single Jest file: `yarn unit-test path/to/test_file.test.js`

### Lint
- Ruby lint: `bundle exec rubocop`
- Helm lint used in CI:
  - `helm lint helm_deploy --values helm_deploy/values-dev.yaml --set redis.auth.password=dummy --set postgresql.auth.password=dummy`
  - Repeat for `values-uat.yaml` and `values-prod.yaml` as needed.

## High-level architecture

- This is a Rails app serving three caseworker domains:
  - `nsm` (non-standard magistrates)
  - `prior_authority`
  - `payments`
- Controllers, forms, params validators, and views are namespaced per domain (`app/controllers/nsm`, `app/controllers/prior_authority`, `app/controllers/payments`, etc.).

- Domain submission data is sourced from App Store APIs, not just local ActiveRecord records:
  - `AppStoreClient` handles HTTP calls to app-store endpoints.
  - `Submission.load_from_app_store` / `Submission.rehydrate` convert API payloads into domain models (`Claim`, `PriorAuthorityApplication`).
  - Search/list pages use `SearchResults` + namespaced `app/view_models/*/v1/*` classes that call app-store search endpoints.

- Payments flow is a multi-step wizard:
  - Step controllers inherit from `Steps::BaseStepController` (or `Payments::Steps::BaseController`).
  - Routing uses `edit_step` helper (`lib/route_helpers.rb`) to define edit/update step endpoints.
  - Step transitions are controlled in `Decisions::DecisionTree`.
  - In-progress answers are stored in `Decisions::MultiStepFormSession` in the Rails session.

- Shared request lifecycle is centralized in `ApplicationController`:
  - Authentication (`devise`), authorization (`pundit`), cookie handling, access logging, maintenance mode checks.
  - `after_action :verify_authorized` means controller actions are expected to call `authorize`.
  - `check_controller_params` runs a per-controller `param_validator` and raises on invalid params.

## Key conventions in this codebase

- **Param validation pattern is enforced in controllers**  
  Define `controller_params` + `param_validator` using classes in `app/param_validators/**`. Invalid params raise before action logic.

- **Always wire Pundit authorization in controller actions**  
  Because `ApplicationController` uses `after_action :verify_authorized`, actions should call `authorize(...)` (or authorize list/index explicitly).

- **Use Rails 8 `params.expect` for form payloads**  
  Many controllers use `params.expect(...)` for required nested form keys, not only `permit`.

- **Payments step forms follow `BasePaymentsForm` contract**  
  Build with `.build(form_data, multi_step_form_session:)`; persist by writing attributes back into session-backed `MultiStepFormSession`.

- **Feature flags drive routes and behavior**  
  Flags are defined in `config/feature_flags.yml` and consumed via `FeatureFlags.<flag>.enabled?` (e.g., `payments`, `dev_auth`, `youth_court_fee`, `provider_api`).

- **Namespace/versioned view model lookup is dynamic**  
  `BaseViewModel.build` resolves classes from submission namespace + schema version (`Namespace::V<json_schema_version>::...`). Keep naming aligned with this convention.
