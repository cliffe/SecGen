//The intial function called, sets up the webpage.
function initialise()
{
  //Read the storys from the xml and put it on the webpage.
  requestStorys();
}

//Request the data for the storys.
function requestStorys()
{
  //Load the list of storys.
  requestData("news-stories/story-list.xml", loadStorys);
}

//Request data to be passed into a function.
function requestData(url, callBack)
{
  //Create a new XMLHttpRequest object
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function()
  {
    if(xmlhttp.readyState == 4)
    {
      callBack(xmlhttp);
    }
  }

  //Open the object with the filename
  xmlhttp.open("POST", url, true);
  //Send the request
  xmlhttp.send(null)
}

//Load all of the storys onto the page asynchronously.
function loadStorys(xmlhttp)
{
  //Get the xml content from the file.
  var xml_story_list = xmlhttp.responseXML;
  //Get all of the storys.
  var xml_storys = xml_story_list.getElementsByTagName("story");

  //Loop through all of them.
  for(var i=0; i<xml_storys.length; i++)
  {
    //Get the file name of the story.
    var filename = xml_storys[i].textContent;
    //Request that story.
    requestStory("/news-stories/" + filename + ".xml", i, loadStory);
  }
}

//Request a story to be passed into a function.
function requestStory(url, storyNum, callBack)
{
  //Create a new XMLHttpRequest object
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function()
  {
    if(xmlhttp.readyState == 4)
    {
      callBack(xmlhttp, storyNum);
    }
  }

  //Open the object with the filename
  xmlhttp.open("POST", url, true);
  //Send the request
  xmlhttp.send(null)
}

//Load the story into the page.
function loadStory(xmlhttp, storyNum)
{
  //Get the xml content from the file.
  var xmlStory = xmlhttp.responseXML;
  //Select the story
  var story_doc = xmlStory.getElementsByTagName("story");

  //If there is not story, then exit from the function.
  if(story_doc.length != 1)
  {
    return;
  }

  //Get the key data.
  var author = story_doc[0].getElementsByTagName("author")[0].textContent;
  var date = story_doc[0].getElementsByTagName("date")[0].textContent;
  var headline = story_doc[0].getElementsByTagName("headline")[0].textContent;
  var subheading = story_doc[0].getElementsByTagName("subheading")[0].textContent;
  var article = story_doc[0].getElementsByTagName("article")[0];

  //Store all the data in one object.
  var story = 
  {
    author : author,
    date : date,
    headline : headline,
    subheading : subheading,
    article : article
  }

  //Draw the story onto the html.
  drawStory(story, storyNum);
}

//Draw all of the storys stored in the storys array.
function drawStory(story, storyNum)
{
  //Select the story preview list.
  var preview_list = document.getElementById("preview_list").getElementsByTagName("ul")[0];

  //Select the story list.
  var story_list = document.getElementById("story_pane").getElementsByTagName("ul")[0];

  //Create a new preview list item.
  var preview_list_li = document.createElement("li");
    
  //Set the class of the list item to be a preview.
  preview_list_li.setAttribute("class", "preview");
  //Set the id of the list item.
  preview_list_li.setAttribute("id", "preview_" + storyNum);
    
  //Create a new h3 heading.
  var preview_headline = document.createElement("h3");
  //Set the headline to be the story headline.
  preview_headline.innerHTML = story.headline;
  //Add the headline to the preview.
  preview_list_li.appendChild(preview_headline);

  //Create a new h5 subheading.
  var preview_subheading = document.createElement("h5");
  //Set the subheading to be the story subheading.
  preview_subheading.innerHTML = story.subheading;
  //Add the subheading to the preview.
  preview_list_li.appendChild(preview_subheading);

  //Add the new list item to the preview list.
  preview_list.appendChild(preview_list_li);

  //Create new story list item.
  var story_li = document.createElement("li");

  //Set the class of the list item to be a story.
  story_li.setAttribute("class", "story");
  //Set the id of the list item.
  story_li.setAttribute("id", "story_" + storyNum);
  
  //Create new h1 headline.
  var headline = document.createElement("h1");
  //Set it to be the headline of the story.
  headline.innerHTML = story.headline;
  //Add the headline to the story.
  story_li.appendChild(headline);

  //Create new h3 subheading.
  var subheading = document.createElement("h3");
  //Set it to be the subheading of the story.
  subheading.innerHTML = story.subheading;
  //Append it to the story.
  story_li.appendChild(subheading);

  //Create new h4 author.
  var author = document.createElement("h4");
  //Set it to be the author of the story.
  author.innerHTML = story.author;
  //Append it to the story.
  story_li.appendChild(author);

  //Create new h4 date.
  var date = document.createElement("h4");
  //Set it to be the date the story was written.
  date.innerHTML = story.date;
  //Append it to the story.
  story_li.appendChild(date);

  //Create new div for the article.
  var article = document.createElement("div");
  //Set the class to article.
  article.setAttribute("class", "article");
  //Get all of the <p> tags in the article.
  var paragraphs = story.article.getElementsByTagName("p");
  //Loop through all of them.
  for(var i=0; i<paragraphs.length; i++)
  {
    //Create new p tag.
    var p = document.createElement("p");
    //Set it to be one of the paragraphs in the article.
    p.innerHTML = paragraphs[i].textContent;
    //Append it to the article.
    article.appendChild(p);
  }
  //Append the article to the story.
  story_li.appendChild(article);

  //Append the story item to the list of storys.
  story_list.appendChild(story_li);

  //Setup the story to be hidden.
  setupStory(story_li, storyNum);

  //Setup the preview to select the correct story.
  setupPreview(preview_list_li, storyNum);
}

//Setup all of the storys (except the first) to be hidden.
function setupStory(story_item, storyNum)
{
  //Check the story number.
  switch(storyNum)
  {
    //If it's the first story:
    case 0 :
    {
      //Show it.
      showStory("story_0");
      return;
    }

    //If it's any other story:
    default :
    {
      //Hide it.
      story_item.setAttribute("class", "hidden_story");
    }
  }
}

//Shows the storys that has an id of storyID.
function showStory(storyID)
{
  //Select any open story.
  var storys = document.getElementsByClassName("story");
  //If it exists:
  if(storys.length > 0)
  {
    //Set it to be a hidden story
    storys[0].setAttribute("class", "hidden_story");
  }

  //Select the desired story.
  var story = document.getElementById(storyID);

  //Set the class to be a story.
  story.setAttribute("class", "story");
}

//Setup the previews to show the correct story.
function setupPreview(preview_item, storyNum)
{
  if(storyNum == 0)
  {
    markPreview("preview_0")
  }

  //Upon clicking on the preview, do the following:
  preview_item.onclick = function()
  {
    //Get the ID of the preview
    var previewID = this.getAttribute("id");
    //Split the preview ID to get the number.
    var previewIDNum = previewID.split("_");
    //Convert this to an ID of a story.
    var storyID = "story_" + previewIDNum[previewIDNum.length-1];
    //Show the correct story.
    showStory(storyID);
    //Mark the preview as shown.
    markPreview(previewID);
  }
}

//Mark a preview with id of previewID, this is to highlight the story being read.
function markPreview(previewID)
{
  //Select the currently marked preview.
  var marked = document.getElementsByClassName("marked_preview");
  //If there is a marked preview.
  if(marked.length > 0)
  {
    //Set it as a normal preview.
    marked[0].setAttribute("class", "preview");
  }

  //Select the preview to be marked.
  var preview = document.getElementById(previewID);
  //Set the class as a marked preview.
  preview.setAttribute("class", "marked_preview");
}
