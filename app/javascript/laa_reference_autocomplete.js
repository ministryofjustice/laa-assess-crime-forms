import accessibleAutocomplete from 'accessible-autocomplete'
import $ from 'jquery'

function customInput(result){
  return result?.value
}

function customSuggestion(result){
  if(result?.description && result?.value){
    return `${result.description}`
  }
  else{
    return ""
  }

}

async function referenceSearch(query){
  try{
    let response = await fetch(`/laa_references/search?query=${query}`)
    if(response.ok){
      const references = await response.json()
      return references
    }
    else{
      return []
    }
  }
  catch{
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
      minLength: 2
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
