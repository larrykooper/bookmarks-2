// REGISTER EVENT LISTENERS

// Letting user delete a bookmark, but forcing them to confirm
$(document).on("click", ".delete_button_span", confirmAndDelete);

// Sorting the tags in the sidebar when the user asks for it
$(document).on("click", ".sorter", displayTagsInResponseToClick);

// Show the tags in sidebar with JS on page load
document.addEventListener("turbolinks:load", function() {
  var orderWanted, page, $ts;
  orderWanted = "alpha";
  $ts = $(".tags_sidebar");
  if ($ts.length) {
    // tags_sidebar is there
    console.log("tags_sidebar is there");
    if ($ts.hasClass("in_rotation")) {
      page = "in_rotation";
    } else {
      page = "bookmarks";
    }
    getTags(orderWanted, page)
  }
})

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

  if (parent.hasClass("in_rotation")) {
    page = "in_rotation";
  } else {
    page = "bookmarks";
  }
  getTags(orderWanted, page);

}

function getTags(orderWanted, page) {
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
        <a href="bookmarks?tags=${id}">${name}</a>
      </div>
    `;
    place.append(oneTagHtml);
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