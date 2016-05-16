# Ruby Key Server

## Requirements


Write a server which can generate random api keys, assign them for usage and
release them after sometime. Following endpoints should be available on the
server to interact with it.  

E1. There should be one endpoint to generate keys.

E2. There should be an endpoint to get an available key. On hitting this
endpoint server should serve a random key which is not already being used. This
key should be blocked and should not be served again by E2, till it is in this
state. If no eligible key is available then it should serve 404.

E3. There should be an endpoint to unblock a key. Unblocked keys can be served
via E2 again.

E4. There should be an endpoint to delete a key. Deleted keys should be purged.

E5. All keys are to be kept alive by clients calling this endpoint every 5
minutes. If a particular key has not received a keep alive in last five minutes
then it should be deleted and never used again. 

Apart from these endpoints, following rules should be enforced:

R1. All blocked keys should get released automatically within 60 secs if E3 is
not called.

No endpoint call should result in an iteration of whole set of keys i.e. no
endpoint request should be O(n). They should either be O(lg n) or O(1).

## Setting up the server

To install the required gems, run `$bundle install` in the repo directory.

For setting up the server, execute: 

`$ rackup -p 9000`

(where `-p` specifies the port for running the server)

## API Endpoints

- '/'  
  Outputs 'OK' if the server is up and running

- '/keys'  
  Generates default number (3) of keys and outputs them separate by a new line

- '/key'  
  Retrieve a free key if available. If it's not available a 404 error is raised.

- '/key/unblock/:id'  
  Unblocks the given key. Raises an error on invalid input.   

- '/key/delete/:id'  
  Deletes the given key permanently. Raises an error on invalid input.   

- '/key/keep/:id'  
  Updates timestamp of the given key. Refreshes the timer of a key if it is
  within the 60 second blocking limit. Raises an error on invalid input.

## Testing
                                                                                            
For executing the specs (unit testing), execute the following command:
                                        
`$ bundle exec rspec --format documentation --color`

On completion, the following output is obtained after successfully passing each
test:

![rspecs passing](https://dl.dropboxusercontent.com/u/91231499/Hosting/KeyServerSpecs.png)
