
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define("getMyFacialImages", function(request, response) {
  var query = new Parse.Query("FaceImage");
  query.equalTo("createdBy", request.user);
  query.find({
    success: function(results) {
      response.success({"faceImages":results});
    },
    error: function() {
      response.error("failed");
    }
  });
});