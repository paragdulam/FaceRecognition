
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

//paragdulam@gmail.com
var apiKey = "e44271416fb544759ca1b88e4a337034";
var apiSecretKey = "4a1e752996404ace987b52d6d22a4a34";
var baseURL = "http://api.skybiometry.com/fc/";

//paragdulam@yahoo.co.in
// var apiKey = "99b77d7e55d24bb5bf6cb5c6d9ee9b1a";
// var apiSecretKey = "a9f78fd1d5654c92a3ed4d57d28c8ef0";
// var baseURL = "http://api.skybiometry.com/fc/";



Parse.Cloud.define("getFaceImages", function(request,response) {
  var uid = request.params.uid;
  var userInfo = Parse.Object.extend("UserInfo");
  var userQuery = new Parse.Query(userInfo);
  userQuery.equalTo("facebookId", uid);  
    userQuery.find({
      success: function(users) {
        if (users.length) {
          var user = users[0];
          console.log("name "+user.name);
          var faceImage = Parse.Object.extend("FaceImage");
          var query = new Parse.Query(faceImage);
            query.equalTo("createdBy",user.get("User"));
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
      } else {
        response.success([]);
      }
    },
    error :function(error) {
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
    },
    error: function(httpResponse) {
      console.log(httpResponse.text);
      response.error(httpResponse.error);
    }
  });
});


Parse.Cloud.define("trainFaceImage", function(request,response) {
  var uids = request.params.uids;
  var trainURL = baseURL + "faces/train.json?api_key=" + apiKey + "&api_secret=" + apiSecretKey + "&uids=" + uids;  
  Parse.Cloud.httpRequest({
    method: 'GET', 
    url: trainURL,
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



Parse.Cloud.define("matchWithAllUsers", function(request,response) {
  var namespace = request.params.namespace;
  var urls = request.params.urls;
  var usersURL = baseURL + "account/users.json?api_key=" + apiKey + "&api_secret=" + apiSecretKey + "&namespaces=" + namespace;  
    Parse.Cloud.httpRequest({
      method: 'GET', 
      url: usersURL,
      headers:{
        "Content-Type":"application/json"
      },
      success: function(httpResponse) {
        console.log(httpResponse.text);
        var users = httpResponse.data["users"];
        var appUsers = users[namespace];
        var uids = appUsers.join();
        var recognizeURL = baseURL + "faces/recognize.json?api_key=" + apiKey + "&api_secret=" + apiSecretKey + "&uids=" + uids + "&urls=" + urls;
        Parse.Cloud.httpRequest({
          method: 'GET', 
          url: recognizeURL,
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

Parse.Cloud.define("getLookalikes", function(request,response) {
  var faceImageId = request.params.faceImageId;
  Parse.Cloud.run("detectFace", { "faceImageId": faceImageId }, {
    success:function(detectFaceResponse) {
      var tid = detectFaceResponse.photos[0].tags[0].tid;
      Parse.Cloud.run("getAppNamespace", {}, {
        success:function(getAppNamespaceResponse) {
          var namespace = getAppNamespaceResponse.namespaces[0].name;
          var tobeSavedUid = faceImageId + "@" + namespace;          
          Parse.Cloud.run("saveTag", {"tid":tid,"uid":tobeSavedUid}, {
            success:function(saveTagResponse) {
              Parse.Cloud.run("trainFaceImage", {"uids":tobeSavedUid}, {
                success:function(trainFaceResponse) {
                  var faceImage = Parse.Object.extend("FaceImage");
                  var sourceFaceImageQuery = new Parse.Query(faceImage);
                  sourceFaceImageQuery.equalTo("objectId",faceImageId);
                  sourceFaceImageQuery.find({
                    success:function(fetchedFaceImages) {
                      var fetchedFaceImage = fetchedFaceImages[0];
                      console.log('fid '+fetchedFaceImage.objectId);
                      var imageFile = fetchedFaceImage.get("imageFile");
                      Parse.Cloud.run("matchWithAllUsers",{"namespace":namespace,"urls":imageFile.url()},{
                        success:function(matchResponse){
                          var faceImages = [];
                          var uids = matchResponse.photos[0].tags[0].uids;
                          console.log("uids "+ uids);
                          var index = 0;
                          for (var i = 0; i < uids.length; i++) {
                          var uidDict = uids[i];
                          if (uidDict.confidence >= 70) 
                          {
                            console.log('Found Lookalike '+uidDict.uid);
                            var uid = uidDict.uid;
                            var lookalikeId = uid.split('@')[0];
                            console.log("lookalikeId "+lookalikeId);
                            var faceImage = Parse.Object.extend("FaceImage");
                            var query = new Parse.Query(faceImage);
                            query.equalTo("objectId",lookalikeId);
                            query.find().then(function(results) {
                            // Collect one promise for each addition into an array.
                              console.log("results "+ results);
                              var promises = [];
                              var result = results[0];
                              
                              faceImages[index] = result;
                              index++;

                              promises.push(result.save());
                            // Return a new promise that is resolved when all of the deletes are finished.
                            return Parse.Promise.when(promises);
                            }).then(function() {
                              response.success({"lookalikes":faceImages});
                            });
                          }
                          }
                      },
                        error:function(error){
                          response.error(httpResponse.error); 
                      }
                   })
                },
                error:function(error) {
                  response.error(httpResponse.error); 
                }
              });

                },
                error:function(error) {
                  response.error(error);
                }
              });
            },
            error:function(error) {
              response.error(httpResponse.error); 
            }
          });
        },
        error:function(error) {
          response.error(httpResponse.error);
        }
      });
    },
    error:function(error) {
      response.error(httpResponse.error);
    }
  });
});


