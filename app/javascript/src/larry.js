// REGISTER EVENT LISTENERS

// Letting user delete a bookmark, but forcing them to confirm
//  We only want to execute this when the delete button is on screen
const dbs = document.querySelector(".delete_button_span");

if (dbs) {
  dbs.addEventListener('click', confirmAndDelete);
}

// Sorting the tags in the sidebar when the user asks for it
var sorters = document.getElementsByClassName("sorter");
for (var i = 0; i < sorters.length; i++) {
    sorters[i].addEventListener('click', displayTagsInResponseToClick);
}

// Show the tags in sidebar with JS on page load
window.addEventListener("load", function() {
  var orderWanted, page;
  orderWanted = "alpha";
  const ts = document.querySelector(".tags_sidebar");
  if (ts) {
    // tags_sidebar is there
    let isInroPresent = ts.classList.contains("in_rotation");
    let page = "";
    if (isInroPresent) {
        page = "in_rotation";
    } else {
        page = "bookmarks";
    }
    var tags = getTagsFetch(orderWanted, page);
  }
});

// SORTING THE TAGS IN SIDEBAR

function displayTagsInResponseToClick(event) {
  var alphaElem, freqElem, orderElem, orderWanted, otherElem, page, parent;
  // Figure out which sort order should be bolded
  alphaElem = document.getElementById("alpha");
  freqElem = document.getElementById("freq");
  orderElem = event.target;
  orderWanted = orderElem.getAttribute("id");
  orderElem.classList.remove("bolder");
  otherElem = (orderWanted == "alpha" ? freqElem : alphaElem);
  otherElem.classList.add("bolder");
  // Figure out which page called us
  parent = orderElem.closest(".tags_sidebar");
  page = (parent.classList.contains("in_rotation")) ? "in_rotation" : "bookmarks";
  var tags = getTagsFetch(orderWanted, page);

}

function getTagsFetch(orderWanted, page) {
  window.page = page;
  var url = "/specials/refreshtags?" + new URLSearchParams({
    settagsort: orderWanted,
    page: page
  });

  fetch(url, {
    headers: {
      "Content-Type": "application/json",
    },
  })
    .then(function(serverPromise){
      serverPromise.json()
        .then(function(j) {
          putTagsInHtml(j);
        })
        .catch(function(e){
          console.log(e);
        });
    })
    .catch(function(e){
        console.log(e);
    });


}

// function getTags(orderWanted, page) {
//   window.page = page;
//   // Ajax call
//   $.ajax({
//     url: "/specials/refreshtags",
//     data: {
//       settagsort: orderWanted,
//       page: page
//     },
//     success: putTagsInHtml,
//     error: handleAjaxError
//   });
// }
//

function putTagsInHtml(data) {
  var count, id, name, i, link, oneTag, oneTagHtml;
  var page = window.page;
  const place = document.querySelector("#all-the-tags");
  link = (page == "bookmarks") ? "bookmarks" : "showinro"
  place.innerHTML = "";
  for (i = 0; i < data.length; i++) {
    count = data[i].count;
    id = data[i].id;
    name = data[i].name;
    var oneTagHtml = `
      <div class="tag">
        ${count}
        <a href="${link}?tags=${id}">${name}</a>
      </div>
    `;
    place.innerHTML += oneTagHtml;
  } // end of for
}

function handleAjaxError(jqXHR, textStatus, errorThrown) {
  $('.alert').text(errorThrown);
}

// "ARE YOU SURE YOU WANT TO DELETE?"

function confirmAndDelete(event) {
  var result;
  const theform = document.getElementsByClassName("edit_bookmark")[0];
  result = confirm("Are you sure?");
  if (result) {
    theform.submit();
  } else {
    const notice = document.getElementsByClassName("notice")[0];
    notice.innerHTML = "Bookmark was not deleted.";
  }
}