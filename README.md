Kincurrent
==========

What is this? Basically it's a social api.  You can create users, groups and post to streams.  

Technologies:
Sinatra  (Probably would have been easier to use Rails but wanted to try it out)
OrientDB (http://www.orientechnologies.com/  Great Graph/Document database)
Postgres 
RabbitMQ  (http://www.rabbitmq.com/)
Torquebox (http://torquebox.org/    all-in-one environment, built upon the latest JBoss AS Java application server and JRuby)

For postgres I'm using Datamapper (http://datamapper.org/)
For OrientDB I'm using Oriented (github.com/kmussel/oriented)



### Setup:

#clone repo:
 git clone git@github.com:frenzylabs/kincurrent.git

#Install Gems
 bundle install 

# Install OrientDB
 brew install orientdb  
* depends on the version this installs - at the moment I'm using 2.0-M3 so might have to just download it at http://www.orientechnologies.com/download/

# Install RabbitMQ
 brew install rabbitmq

# Setup OrientDB Server:
  First need to setup user
  -- Go to installation config directory
  -- Edit orientdb-server-config.xml
  -- Go to <users> and add <user resources="*" password="family" name="kincurrent"/>
      You can make this whatever you want just make sure you change the application config/orientdatabase.rb file to reflect it
  -- save it  
  
  Go to installation bin directory and run command "./server.sh"
  
  Create The Database
    - Multiple ways to create the db but easy way is to go to localhost:2480
    - Click on "New DB" button
      Name:            kincurrent_development
      Type:            graph
      Store Type:      plocal
      Server User:     kincurrent
      Server Password: family (or whatever you added in the server-config.xml file)
    - Click Create database

# Run OrientDB schema migration scripts
RAILS_ENV=development ruby lib/tasks/orientdb_task.rb create_schema    
  
  


# Setup RabbitMQ Server (users/virtual hosts/exchanges)
run command "rabbitmq-server"

go to rabbitmq server management address -  http://localhost:15672
go to admin tab
select virtual hosts and click add virtual host
name:  dev
click add virtual host

go to users section and click add a user
username: rabbit
password: rabbit
(you can change these to whatever you want just make sure to change the config/application.yml file to what you make these)
click Add user
then select the user to handle permissions
Set permission 
Virtual Host: dev
Can leave the defaults for the rest for now (.*)


Go to Exchanges tab:
Add a new exchange:
Virtual host: dev
Name: streams
Type: topic
Durability: Durable
Auto delete: No
Internal: No


## Start Web Server:
torquebox deploy
torquebox start

Web URL:
http://localhost:8080

OrientDB URL
http://localhost:2480

RabbitMQ URL
http://localhost:15672


ORIENTDB:
Inside config/orientdatabase.rb
We initialize orientdb
we map the ruby classname to the orientdb schema classname


## Application Info:

sinatra app
  runs and validates commands
  creates the event storing the results of the command in json format
  publishes the event to rabbitmq exchange 
    - 2 ways to publish event
      1. Asynchronous method of Rabbitmq.publish(message = "", route = "#", exchange = "streams", headers = {})
      2. Synchronous (Remote Procedure Call) use Rpc.publish(message = "", route = "#", exchange = "streams", headers = {})
        - This one creates a new instance of Rpc and subscribes to its own queue.
          It then calls the asynchronous method but uses a mutex to lock the thread until it 
          receives a reply back from the publish method.  

Torquebox Services:
  projection_server
    RabbitMQ subscriber
      - listens to published events  (The event name corresponds to a method on the projection object)
      - on event, loops through all the projections to see if any of them responds to the event name
        - if the projection does respond, will run it to create the models
        - the event is then marked as processed and the projection is updated with the last event id it processed. 
        - publishes results to another exchange for anyone that is subscribed to be notified in realtime 
        - If the headers of the event contain a reply_to key then will also publish the results to default exchange with reply_to as the route. (this happens now when you use the Synchronous method to publish the event)
        
        



