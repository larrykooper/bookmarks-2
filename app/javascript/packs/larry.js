console.log("I am here in larry.js")

$(document).ready(doThisOnDocumentReady);

function doThisOnDocumentReady() {
  console.log("DOCUMENT READY");

  // Letting user delete a bookmark, but forcing them to confirm
  $("#delete_bookmark_button").on("click", confirmAndDelete);

  // Sorting the tags in the sidebar when the user asks for it
  $(".sorter").on("click", sortTagsServerSide);
}

// SORTING THE TAGS

function sortTagsServerSide(event) {
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
  if (parent.hasClass("bookmarks")) {
    page = "bookmarks";
  } else {
    page = "in_rotation";
  }
  // Ajax call
  $.ajax({
    url: "/specials/refreshtags",
    data: {
      settagsort: orderWanted,
      page: page
    },
    success: putTagsInHtml,
    error: handleAjaxError
  });
}

function putTagsInHtml(data) {
  var count, id, name, i, oneTag, oneTagHtml;
  var place = $("#all-the-tags");
  place.html("")
  for (i = 0; i < data.length; i++) {
    count = data[i].count;
    id = data[i].id;
    name = data[i].name;
    var oneTagHtml = `
      <div class="tag">
        ${count}
        <a href="bookmarks/tags='${id}'">${name}</a>
      </div>
    `;
    place.append(oneTagHtml);
  } // end of for
}

function handleAjaxError(jqXHR, textStatus, errorThrown) {
  $('.alert').text(errorThrown);
}


function confirmAndDelete(event) {
  var conf, result, theform;
  console.log("in confirmAndDelete");
  theform = $(".edit_bookmark")[0]
  result = confirm("Are you sure?");
  if (result) {
    console.log("You clicked OK button!");
    theform.submit();
  } else {
    console.log("You clicked Cancel button!");
    $(".notice").text("Bookmark was not deleted.");
  }
}