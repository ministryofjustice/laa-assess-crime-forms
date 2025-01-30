# Assess non standard magistrates fee

* Ruby version
ruby 3.3.6

* Rails version
rails 7.0.42.0

## Getting Started

Clone the repository, and follow these steps in order.
The instructions assume you have [Homebrew](https://brew.sh) installed in your machine, as well as use some ruby version manager, usually [rbenv](https://github.com/rbenv/rbenv). If not, please install all this first.

### 1. Pre-requirements

* `brew bundle`
* `gem install bundler`
* `bundle install`

### 2. Configuration

* Copy `.env.development` to `.env.development.local` and modify with suitable values for your local machine
* Copy `.env.test` to `.env.test.local` and modify with suitable values for your local machine

```
# amend database url to use your local superuser role, typically your personal user
DATABASE_URL=postgresql://postgres@localhost/laa-assess-crime-forms-dev
=>
DATABASE_URL=postgresql://john.smith@localhost/laa-assess-crime-forms-dev
```

After you've defined your DB configuration in the above files, run the following:

* `bin/rails db:prepare` (for the development database)
* `RAILS_ENV=test bin/rails db:prepare` (for the test database)

### 3. GOV.UK Frontend (styles, javascript and other assets)

* `yarn install --frozen-lockfile`
* `rails assets:precompile` [require on first occassion at least]

### 4. Database preparation

#### Seed data

To reduce the overhead and complexity of creating and updating seed data to rake
task have been added which can be used to either load the existing see data into
the system, or export data that has been generated via the Provide/App Store route.

#### Loading data

```
rails custom_seeds:load
```

This reads the folders in db/seeds and loads the claim and the latest version data.
Any existing data for that claim will automatically be deleted during the import
process.

By default all folders are processed during the load.

#### Storing data

```
rake custom_seeds:store[<claim_id>]
```

Records are stored based off of the claim ID and need to be processed one at a time.
It is expected that records will be generated in the Provider app and sent across
as opposed to being manually generated to avoid creating invalid data records.


#### Adding users

```
rake user:add["first_name.last_name@wherever.com","first_name","last_name","my_role"]
```

To add a user into the database that can be authenticated into the app, use the command above.

On UAT the email must be an MoJ AzureAD email address (i.e. ending @justice.gov.uk) as
omniauthentication is handed off to AzureAD.

### 5. Run app locally

Once all the above is done, you should be able to run the application as follows:

`rails server` - will only run the rails server, usually fine if you are not making changes to the CSS.

You can also compile assets manually with `rails assets:precompile` at any time, and just run the rails server, without foreman.

If you ever feel something is not right with the CSS or JS, run `rails assets:clobber` to purge the local cache.

### 6. Sidekiq Auth

We currently protect the sidekiq UI on production servers (Dev, UAT, Prod, Dev-CRM4) with basic auth.

In order to extract the password from the k8 files run the following commands:

> NOTE: this requires your kubectl to be setup and [authenticated](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/kubectl-config.html#authenticating-with-the-cloud-platform-39-s-kubernetes-cluster) as well as having [`jq`](https://jqlang.github.io/jq/download/) installed.
```bash
NAMESPACE=laa-assess-crime-forms-dev

kubectl config use-context live.cloud-platform.service.justice.gov.uk
# username
kubectl get secret sidekiq-auth -o jsonpath='{.data}' --namespace=$NAMESPACE | jq -r '.username' | base64 --decode && echo " "
# password
kubectl get secret sidekiq-auth -o jsonpath='{.data}' --namespace=$NAMESPACE | jq -r '.password' | base64 --decode && echo " "
```

### 7. Tests

To run the test suite, run `bundle exec rspec`.
This will run everything except for the accessibility tests, which are slow, and by default only run on CI.
To run those, run `INCLUDE_ACCESSIBILITY_SPECS=1 bundle exec rspec`.
Our test suite will report as failing if line and branch coverage is not at 100%.
We expect every feature's happy path to have a system test, and every screen to have an accessibility test.


### 8. Development end-to-end setup

see [Development e2e setup](https://github.com/ministryofjustice/laa-submit-crime-forms/blob/main/docs/development-e2e-setup.md)

### 9. Developing

#### Overcommit

[Overcommit](https://github.com/sds/overcommit) is a gem which adds git pre-commit hooks to your project. Pre-commit hooks run various
lint checks before making a commit. Checks are configured on a project-wide basis in .overcommit.yml.

To install the git hooks locally, run `overcommit --install`. If you don't want the git hooks installed, just don't run this command.

Once the hooks are installed, if you need to you can skip them with the `-n` flag: `git commit -n`

#### API keys
To send emails, you will need to generate a notifications API key. You can generate a test key at https://www.notifications.service.gov.uk/
Add it to your.env.development.local under GOVUK_NOTIFY_API_KEY

To use the location service you will need an Ordnance Survey API key. You can generate a test key at https://osdatahub.os.uk/projects. Create and account, create a test project, add the OS Names API to that project, then move its key to OS_API_KEY in .env.development.local

### 10. Helm Template

#### Security Context
We have a default [k8s security context ](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#securitycontext-v1-core) defined in our _helpers.tpl template file. It sets the following:

- runAsNonRoot - Indicates that the container must run as a non-root user. If true, the Kubelet will validate the image at runtime to ensure that it does not run as UID 0 (root) and fail to start the container if it does. Currently defaults to true, this reduces attack surface
- allowPrivilegeEscalation - AllowPrivilegeEscalation controls whether a process can gain more privileges than its parent process. Currently defaults to false, this limits the level of access for bad actors/destructive processes
- seccompProfile.type - The Secure Computing Mode (Linux kernel feature that limits syscalls that processes can run) options to use by this container. Currenly defaults to RuntimeDefault which is the [widely accepted default profile](https://docs.docker.com/engine/security/seccomp/#significant-syscalls-blocked-by-the-default-profile)
- capabilities - The POSIX capabilities to add/drop when running containers. Currently defaults to drop["ALL"] which means all of these capabilities will be dropped - since this doesn't cause any issues, it's best to keep as is for security reasons until there's a need for change

### 11. Controller Param Validation

We have an additional layer of security in our controllers to validate url parameters via "Param Validators" which exist in the [param_validator directory](app/param_validators). These use [ActiveModel](https://api.rubyonrails.org/classes/ActiveModel/Model.html) to define expectations of parameters used within the controller. We then have the ability to use the valid? method or check individual validation errors to handle actions accordingly for invalid params. This is not a replacement for constraints and we should still use those when we want to definitely block certain request configurations (e.g. blocking a list of ip addresses).

## Maintenance Mode
This service has a maintenance mode which can be used to prevent users taking actions on the system.

You can use the enable_maintenance_mode/disable_maintenance_mode scripts via `sh bin/enable_maintenance_mode <namespace>` or `sh bin/disable_maintenance_mode <namespace>`.

If you want to change maintenance mode on a branch deployment, add the branch release name as a 2nd arg like this `sh bin/enable_maintenance_mode <namespace> <branch release name>`

The helm_deploy/templates/configuration.yaml file initialises the ConfigMap that is used to store the setting. It only re-generates if the ConfigMap does not exist (using a lookup to check) so that new deployments won't reset the setting and has helm.sh/resource-policy of keep so that the deployment doesn't delete the ConfigMap when we don't want to re-generate it.

If the ConfigMap is deleted for whatever reason, simply restart the deployment and the ConfigMap will get regenerated with default values.

If you want to update the ConfigMap's defaults or metadata, you need to delete the existing resource to allow the updates to feed in. This will also reset the values back to default.

## Licence

This project is licensed under the [MIT License][mit].

[mit]: LICENCE
