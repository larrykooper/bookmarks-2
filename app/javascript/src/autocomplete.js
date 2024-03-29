console.log("I am here in autocomplete.js")

// Credit: https://www.w3schools.com/howto/howto_js_autocomplete.asp

$(document).on('turbolinks:load', function(event) {
  console.log("turbo load");
  if ($("#tagSearch").length) {

    autocomplete(document.getElementById("tagSearch"), "/tags/index", document.getElementById("tagEntry"));

  }
});

function autocomplete(inp, source, dest) {
  console.log("in func autocomplete");

  /*the autocomplete function takes two arguments,
  the text field element and (source) a URL to do lookup */
  var currentFocus;
  /*execute a function when someone writes in the text field:*/

  inp.addEventListener("input", function(e) {
      var a, b, i, val = this.value;
      console.log("in addEventListener");
      /*close any already open lists of autocompleted values*/
      closeAllLists();
      if (!val) { return false;}
      currentFocus = -1;
      /*create a DIV element that will contain the items (values):*/
      a = document.createElement("DIV");
      a.setAttribute("id", this.id + "autocomplete-list");
      a.setAttribute("class", "autocomplete-items");
      /*append the DIV element as a child of the autocomplete container:*/
      this.parentNode.appendChild(a);
      window.val = val;
      window.a = a;
       // Ajax call
      $.ajax({
        url: source,
        data: {
          term: val
        },
        success: putUpChoices,
        error: handleAjaxError
      });

  });  // inp.addEventListener
  /*execute a function presses a key on the keyboard:*/
  inp.addEventListener("keydown", function(e) {
      var x = document.getElementById(this.id + "autocomplete-list");
      if (x) x = x.getElementsByTagName("div");
      if (e.keyCode == 40) {
        /*If the arrow DOWN key is pressed,
        increase the currentFocus variable:*/
        currentFocus++;
        /*and and make the current item more visible:*/
        addActive(x);
      } else if (e.keyCode == 38) { //up
        /*If the arrow UP key is pressed,
        decrease the currentFocus variable:*/
        currentFocus--;
        /*and and make the current item more visible:*/
        addActive(x);
      } else if (e.keyCode == 13) {
        /*If the ENTER key is pressed, prevent the form from being submitted,*/
        e.preventDefault();
        if (currentFocus > -1) {
          /*and simulate a click on the "active" item:*/
          if (x) x[currentFocus].click();
        }  // if currentFocus
      }  // if keyCode == 13
  });  //inp.addEventListener

  function addActive(x) {
    /*a function to classify an item as "active":*/
    if (!x) return false;
    /*start by removing the "active" class on all items:*/
    removeActive(x);
    if (currentFocus >= x.length) currentFocus = 0;
    if (currentFocus < 0) currentFocus = (x.length - 1);
    /*add class "autocomplete-active":*/
    x[currentFocus].classList.add("autocomplete-active");
  } // addActive
  function removeActive(x) {
    /*a function to remove the "active" class from all autocomplete items:*/
    for (var i = 0; i < x.length; i++) {
      x[i].classList.remove("autocomplete-active");
    }
  } // removeActive

  function closeAllLists(elmnt) {
    /*close all autocomplete lists in the document,
    except the one passed as an argument:*/
    var x = document.getElementsByClassName("autocomplete-items");
    for (var i = 0; i < x.length; i++) {
      if (elmnt != x[i] && elmnt != inp) {
      x[i].parentNode.removeChild(x[i]);
    }
  }
}  // closeAllLists

function putUpChoices(data) {
  console.log("in putUpChoices");
  var chosen;
  var val = window.val;
  var a = window.a;
  for (i = 0; i < data.length; i++) {
    console.log("in the for loop")
    /*create a DIV element for each matching element:*/
    b = document.createElement("DIV");
    /*make the matching letters bold:*/
    b.innerHTML = "<strong>" + data[i].substr(0, val.length) + "</strong>";
    b.innerHTML += data[i].substr(val.length);
    /*insert a input field that will hold the current array item's value:*/
    b.innerHTML += "<input type='hidden' value='" + data[i] + "'>";
    /*execute a function when someone clicks on the item value (DIV element):*/
    b.addEventListener("click", function(e) {
      chosen = this.getElementsByTagName("input")[0].value;
      /*insert the value for the autocomplete text field:*/
      inp.value = chosen;
      dest.value += (" " + chosen);
      /*close the list of autocompleted values,
      (or any other open lists of autocompleted values:*/
      closeAllLists();
    });
    a.appendChild(b);
  }

}
function handleAjaxError(jqXHR, textStatus, errorThrown) {
  $('.alert').text(errorThrown);
}

/*execute a function when someone clicks in the document:*/
document.addEventListener("click", function (e) {
    closeAllLists(e.target);
}); // document.addEventListener
} // function autocomplete