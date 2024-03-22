// REGISTER EVENT LISTENERS

// Letting user delete a bookmark, but forcing them to confirm
//  We only want to execute this when the delete button is on screen
// const dbs = document.querySelector(".delete_button_span");

// dbs.addEventListener("click", (event) => {
//   confirmAndDelete;
// });

// Sorting the tags in the sidebar when the user asks for it
const sorter = document.querySelector(".sorter");

if (sorter) {
  sorter.addEventListener("click", (event) => {
    displayTagsInResponseToClick;
  });
}

// Show the tags in sidebar with JS on page load
window.onload = function() {
  console.log("I am in onload function");
  var orderWanted, page, $ts;
  orderWanted = "alpha";
  const ts = document.querySelector(".tags_sidebar");
  if (ts) {
    // tags_sidebar is there
    console.log("tags_sidebar is there");
    let isInroPresent = ts.classList.contains("in_rotation");
    let page = "";
    if (isInroPresent) {
        page = "in_rotation";
    } else {
        page = "bookmarks";
    }
    var tags = getTagsFetch(orderWanted, page);
    putTagsInHtml(tags);

  }
};

// SORTING THE TAGS IN SIDEBAR

function displayTagsInResponseToClick(event) {
  var alphaElem, freqElem, orderElem, orderWanted, otherElem, page, parent;
  // Figure out which sort order should be bolded
  alphaElem = $("#alpha");
  freqElem = $("#freq");
  orderElem = $(event.target);
  orderWanted = orderElem.attr("id");
  orderElem.removeClass("bolder");
  otherElem = (orderWanted == "alpha" ? freqElem : alphaElem);
  otherElem.addClass("bolder");
  // Figure out which page called us
  parent = orderElem.closest(".tags_sidebar");
  page = (parent.hasClass("in_rotation")) ? "in_rotation" : "bookmarks";
  tags = getTagsFetch(orderWanted, page);

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
  var result, theform;
  theform = $(".edit_bookmark")[0]
  result = confirm("Are you sure?");
  if (result) {
    theform.submit();
  } else {
    $(".notice").text("Bookmark was not deleted.");
  }
}