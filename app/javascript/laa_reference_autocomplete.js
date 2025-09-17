import accessibleAutocomplete from 'accessible-autocomplete'
import { FetchRequest } from '@rails/request.js'
import $ from 'jquery'

function customInput(result){
  return result?.reference
}

function customSuggestion(result){
  if(result?.reference && result?.client_surname){
    return `${result.reference} - Defendant ${result.client_surname}`
  }
  else{
    return ""
  }

}

async function referenceSearch(query){
  var token = document.querySelector("meta[name='csrf-token']").content
  const request = new FetchRequest("post", `/laa_references?query=${query}`,
    {
      contentType: "application/json",
      responseKind: "json"
    }
  )
  request.addHeader("X-CSRF-Token", `${token}`)
  const response = await request.perform()
  if (response.ok) {
    const body = await response.json
    return body
  }
  else{
    return []
  }
}

async function customSuggest(query, populateResults){
  const results = await referenceSearch(query)
  populateResults(results)
}

function initAutocomplete(elementId){
  let elements = $(`#${elementId}`)
  if(elements.length > 0){
    let element = elements[0]
    let name = element.getAttribute("data-name")

    accessibleAutocomplete.enhanceSelectElement({
      selectElement: element,
      name: name,
      source: customSuggest,
      templates: {
        inputValue: customInput,
        suggestion: customSuggestion
      },
      autoselect: element.getAttribute('data-autoselect') === "true",
    })
  }
}

$("document").ready(() => {
  let selectElements = $("*[data-module='laa-reference-autocomplete']")

  selectElements.each((index, element) => {
    let elementId = element.id
    //enhance laa-reference-autocomplete tag
    initAutocomplete(elementId)
  })
})
