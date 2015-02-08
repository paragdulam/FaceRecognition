
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

var album = "TwinFinderAlbum";
var albumkey = "e0016d0579b6af8854b8bc41f348e30444f4de4983facec6e7cdae128a23c6e4";
var mashapeKey = 'UR6cNZe0jWmshJTIjaQAEOdVfM02p1BvCy1jsnd3dGcYwJe14p';


Parse.Cloud.afterSave("FaceImage", function(request) {
  var faceImage = request.object;
    Parse.Cloud.httpRequest({
    method: 'POST',
    url: 'https://lambda-face-recognition.p.mashape.com/album_train',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept':'application/json',
      'X-Mashape-Key':mashapeKey
    },
    body: {
      'album': album,
      'albumkey': albumkey,
      'entryid':request.object.id,
      'urls':request.object.get('imageFile').url()
    },
    success: function(httpResponse) {
      console.log(httpResponse.text);
      Parse.Cloud.httpRequest({
        method:'GET',
        url:'https://lambda-face-recognition.p.mashape.com/album_rebuild?album='+album+'&albumkey='+albumkey,
        headers: {
          'Accept':'application/json',
          'X-Mashape-Key':mashapeKey
        },
        success: function(httpResponse) {
          console.log(httpResponse.text);
        },
        error: function(httpResponse) {
          console.error('Request failed with response code ' + httpResponse.status);
        }              
      });
    },
    error: function(httpResponse) {
      console.error('Request failed with response code ' + httpResponse.status);
    }
  });
});