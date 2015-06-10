# Image service API for Rails performance evaluation
The scope of this project is to implement a small API for an image upload social media service modeled after Instagram. It has no real world applications other than
for evaluation performance of Ruby on Rails and will be used as a basis for identifying bottleneck in performance.

The API was implemented according to specification given by [Slagkryssaren]( http://slagkryssaren.com )

## API specifications
| Path               	| Params                                                                                                         	| Response                                                             	|
|--------------------	|----------------------------------------------------------------------------------------------------------------	|----------------------------------------------------------------------	|
| user/signup        	| String: username,  String: email,  String: password,  Date: birthdate,  String: description,  String: gender,  	| 201,  bool:success                                                   	|
| user/login         	| String: username,  String: password                                                                            	| 200,  bool:success                                                   	|
| user/:id           	|                                                                                                                	| 200,  bool: success,  object<User>,  int: following,  int: followers 	|
| users              	| Integer: offset,  Integer: limit                                                                               	| 200,  bool:success,  array<User>                                     	|
| user/:id/followers 	| Integer: offset,  Integer: limit                                                                               	| 200,  bool:success,  array<User>                                     	|
| user/:id/following 	| Integer: offset,  Integer: limit                                                                               	| 200,  bool:success,  array<User>                                     	|
| user/:id/feed      	| Integer: offset,  Integer: limit                                                                               	| 200,  bool:success,  array<Post>                                     	|
| post/create        	| File: image,  String: description,  Array: tags,  Array: user_tags                                             	| 201,  bool:success                                                   	|
| post/:id/update    	| String: description,  Array: tags,  Array: user_tags                                                           	| 200,  bool:success                                                   	|
| post/:id           	|                                                                                                                	| 200,  bool:success, object<Post>                                       	|
| post/:id/like      	|                                                                                                                	| 201,  bool:success                                                   	|
| post/:id/likes     	|                                                                                                                	| 200,  bool:success                                                   	|
| post/:id/comments  	| Integer: offset,  Integer: limit                                                                               	|                                                                      	|
| comment/create     	| Integer: post_id,  String: comment,  Array: tags,  Array: user_tags,                                           	| 201,  bool:success                                                   	|
| comment/:id/update 	| String: comment,  Array: tags,  Array: user_tags                                                               	| 200,  bool:success                                                   	|
| comment/:id        	|                                                                                                                	| 200,  bool:success, object<Comment>                                  	|
