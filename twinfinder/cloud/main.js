
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

var apiKey = "e44271416fb544759ca1b88e4a337034";
var apiSecretKey = "4a1e752996404ace987b52d6d22a4a34";
var baseURL = "http://api.skybiometry.com/fc/";
var appNamespace;


Parse.Cloud.define("getFaceImages", function(request,response) {
  var query = new Parse.Query("FaceImage");
  query.equalTo("createdBy",request.user);

  query.find({
    success: function(results) {
      // results is an array of Parse.Object.
      response.success(results);
    },

    error: function(error) {
      // error is an instance of Parse.Error.
      response.error(error);
    }
  });
});


Parse.Cloud.define("getAppNamespace", function(request,response) {
//http://api.skybiometry.com/fc/account/namespaces.json?api_key=e44271416fb544759ca1b88e4a337034&api_secret=4a1e752996404ace987b52d6d22a4a34
  var namespaceURL = baseURL + "account/namespaces.json?api_key=" + apiKey + "&api_secret=" + apiSecretKey;  
    Parse.Cloud.httpRequest({
    method: 'GET', 
    url: namespaceURL,
    headers:{
      "Content-Type":"application/json"
    },
    success: function(httpResponse) {
      console.log(httpResponse.text);
      response.success(httpResponse.data);
      appNamespace = httpResponse.data.namespaces[0];
    },
    error: function(httpResponse) {
      console.log(httpResponse.text);
      response.error(httpResponse.error);
    }
  });
});


Parse.Cloud.define("matchWithAllUsers", function(request,response) {
  var usersURL = baseURL + "account/users.json?api_key=" + apiKey + "&api_secret=" + apiSecretKey + "&namespaces=" + appNamespace;  
    Parse.Cloud.httpRequest({
      method: 'GET', 
      url: namespaceURL,
      headers:{
        "Content-Type":"application/json"
      },
      success: function(httpResponse) {
        console.log(httpResponse.text);
        var users = httpResponse.data["users"];
        var appUsers = users[appNamespace];
        var uids = appUsers.join();
        var recognizeURL = baseURL + "faces/recognize.json?api_key=" + apiKey + "&api_secret=" + apiSecretKey + "&uids=" + uids;
        Parse.Cloud.httpRequest({
          method: 'GET', 
          url: namespaceURL,
          headers:{
            "Content-Type":"application/json"
          },
          success: function(httpResponse) {
            console.log(httpResponse.text);
            response.success(httpResponse.data);
          },
          error: function(httpResponse) {
          console.log(httpResponse.text);
          response.error(httpResponse.error);
        }
      });
    },
    error: function(httpResponse) {
      console.log(httpResponse.text);
      response.error(httpResponse.error);
    }
  });
});



Parse.Cloud.define("saveTag", function(request,response) {
    var uid = request.params.uid;
    var tid = request.params.tid;
    
    var saveTagURL = baseURL + "tags/save.json?api_key=" + apiKey + "&api_secret=" + apiSecretKey + "&uid=" + uid + "&tids=" + tid;
    Parse.Cloud.httpRequest({
    method: 'GET', 
    url: saveTagURL,
    headers:{
      "Content-Type":"application/json"
    },
    success: function(httpResponse) {
      console.log(httpResponse.text);
      response.success(httpResponse.data);
    },
    error: function(httpResponse) {
      console.log(httpResponse.text);
      response.error(httpResponse.error);
    }
  });
});


Parse.Cloud.define("detectFace", function(request,response) {
  var faceImageId = request.params.faceImageId;

  var query = new Parse.Query("FaceImage");
  query.get(faceImageId, {
  success: function(object) {
    // object is an instance of Parse.Object.
    var faceImage = object;
    var faceDetectURL = baseURL +"faces/detect.json?api_key=" + apiKey + "&api_secret=" + apiSecretKey + "&urls=" + faceImage.get('imageFile').url();
    console.log("detect "+faceDetectURL); 
    Parse.Cloud.httpRequest({
      method: 'GET', 
      url: faceDetectURL,
      headers:{
        "Content-Type":"application/json"
      },
      success: function(httpResponse) {
        console.log(httpResponse.text);
        response.success(httpResponse.data);
      },
      error: function(httpResponse) {
        console.log(httpResponse.text);
        response.error(httpResponse.error);
      }
    });
  },
  error: function(object, error) {
    // error is an instance of Parse.Error.
  }
});


});

