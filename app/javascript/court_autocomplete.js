import accessibleAutocomplete from 'accessible-autocomplete'
import $ from 'jquery'

function customInput(result){
  return result?.short_name
}

function customSuggestion(result){
  if(result?.name){
    return `${result.name}`
  }
  else{
    return ""
  }

}

async function allCourts(){
  try{
    let response = await fetch(`/payments/courts`)
    if(response.ok){
      const courts = await response.json()
      return courts
    }
    else{
      return []
    }
  }
  catch{
    return []
  }
}

export async function customSuggest(query, syncResults){
  let results = await allCourts();
  syncResults(query
    ? results.filter((result) => {
        var resultContains = result.name.toLowerCase().indexOf(query.toLowerCase()) !== -1
        return resultContains
      })
    : []
  )
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

$(function () {
  let selectElements = $("*[data-module='court-autocomplete']")
  selectElements.each((index, element) => {
    let elementId = element.id
    //enhance court-autocomplete tag
    initAutocomplete(elementId)
  })
})
