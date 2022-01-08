# Flowerlook

Restfull API for flowers lovers

## Built with

- Ruby 3.0.2
- Rails 6.1.4.1
- MySQL 8
- Redis 6.2.3

## Env file

```
SECRET_KEY=<your secret key>
JWT_SECRET=<jtw secret>
JWT_TOKEN_DURATION=30 # in minutes
TEST_PASS=<password for test user>

ADD_QUESTION_RETRY_DELAY=60 # in minutes
QUESTION_API_URL=https://opentdb.com/api.php
QUESTION_API_CATEGORY_ID=17
GET_TOKEN_URL=https://opentdb.com/api_token.php?command=request

REDIS_HOST=localhost
```

## Getting started and running

Clone this repo, navigate to the root and then:

- Execute `bundle install` to install needed gems
- Execute `bin/rails db:create` to create databases
- `bin/rails db:migrate` to migrate database
- Create .env file with the content listed above
- Run `bin/rails db:seed` to seed database
- `bin/rails s` will start the server on port 3000
- Open a separate terminal tab and navigate to the project root. Execute `bundle exec sidekiq` to start a Sidekiq worker for adding a question to sighting.

## Tests

Tests can be run with `bundle exec rspec`. Valid .env file is required for running tests

Not whole code and all the scenarios are covered with tests. 
There are four type of the tests:

 - unit tests
 - third party integration tests
 - models test
 - request tests (to test the API flow for certain scenarios)
 
The test data is generated using factory bot and Faker gem.
For testing questions API, the real HTTP request is used. In some cases, this is not the good practice, since API calls to external services can take long time and slowdown the tests. In such cases we can use Webmock or Vcr gem for mocking the HTTP request.
On the other hand, sometimes it is usefull to test the real world API so we can detect the problem if there is one. 
Database cleaner is used for cleaning database after each test.

## Design and implementation concerns

### Validations

Validations are added for all models in the app. Check the table below for details

| Model | Validation |
| --- | --- |
| User | Password needs to have min 8 characters, with at least 1 upper char, 1 lower char, 1 digit and 1 special char|
| User | Username needs to have at least 4 characters and it needs to be unique |
| User | Email needs to in valid format and needs to be unique |
| User | Password confirmation needs to be the same as password |
| User | Email needs to have at least 4 characters and it needs to be unique |
| Flower| Name needs to be at least 3 characters long and unique |
| Flower | Description has to exist |
| Sighting | Combination of latitude and longitude has to be unique |
| Like | User can have only one like on one sighting |

All validations are defined in concern files, to meet the Single Resposibility Principe and to make the code and files organisation cleaner and easier to maintain and extend.

### Database

MySQL database is used as a storage.
Index is created for name column on flowers, to speed up the search of flowers (if later added).

### Services

Two query (ListFlowersQuery and LisSightingsQuery) classes are created to load flowers and sightings respectively. This is the part of the effort to prevent creating FAT controllers. All the associated entities are eagerly loaded when executing this queries, to avoid N+1 query problem. 
For example, if `Flower.all` query is used for listing flowers, then we would have separate query for each flower running on DB when image of the flower is rendered in response. The same goes for sightings and likes and all the other relationships. This would put database under heavy load, especially in case where we deal with huge data volume and high traffic loads.

#### Pagination

Parameters `from` and `to` can be used for pagination. This is the integral part of any API, since we don't want to make our responses contains hundreds or even thousands of items. Paging class is used as a simple implementation of paging. If we need something more robust, we may add more options to it, or use a `will_paginate` or similar gem.

#### Ordering

Objects are sorted by the created date (latest on top) on each endpoint that returns array of objects. This is the subject of improvement, since in some cases we need a support for client to define ordering.

### Adding question

The question is added to each upon sighting creation, using `after_commit` callback. Since adding question involves communication with external API, it is done asynchronously, using Sidekiq gem. If question cannot be added, operation is retried in 60 minutes (configurable period).
If the operation is integral part of the business flow, we could not do it asynchronously. In such cases, we might use ActiveRecord transactions to ensure that sighting save is rolled back if quesiton cannot be added. 
Ruby pattern matching is used for handling all types of the response we get from `opentdb` API. On each request we pass a token, to avoid getting the same questions for a different sightings (as their documentation states). Token is cached in Redis, to avoid unnecessary trips to `opentdb` servers. If Redis token is expired, we refresh it from `opentdb` API. 

### Serializers

`active_record_serializers` gem is used for serializing models in response.

### Configuration

All third party URLs and sensitive data are stored in ENV variables, to meet the Twelve factors app criterias. That way, when some host or third party URL changes, we can just change the environment configuration and restart the service, without a need to make code changes.

### Authorization

JWT token is used for authorization. It has an expiration which is defined in ENV variable. To ensure JWT can be destroyed (on logout), we store it in Redis. Additionally, device_id is associated with each token to ensure that logout on one device does not affect other devices. The whole flow is a subject of improvement. In the real world, we would need to store device_ids and associate them with users.

## Status and Further work

The implementation is still under development.

## API Specification

API returns data in JSON format. API can return one of the following response codes:

- 200 - Ok, data returned
- 400 - Bad Request
- 401 - Unauthorized
- 404 - Not Found

List of the endpoints is below. As API grows, we might use a gem to add OpenAPI specification to our API, so documentation is generated automatically.

### Register

```
curl --location --request POST 'http://localhost:3000/api/v1/register' \
--header 'Content-Type: application/json' \
--data-raw '{
    "user": {
        "username": <username>,
        "password": <password>,
        "password_confirmation": <password>,
        "email": <email>
    }
}'
```

### Login

```
curl --location --request POST 'http://localhost:3000/api/v1/login' \
--header 'Content-Type: application/json' \
--data-raw '{
    "username" : <username>,
    "password" :<password>,
    "device_id" : <device_uuid>
}'
```

### List flowers

```
curl --location --request GET 'http://localhost:3000/api/v1/flowers?from=<from>&to=<to>
```

`from` and `to` are optional. 10 items are returned by default

### List sightings for a specific flower
```
curl --location --request GET 'http://localhost:3000/api/v1/flowers/<flower_id>/sightings?from=<from>&to=<to>' 
```

`from` and `to` are optional. 10 items are returned by default

### Create sighting

```
curl --location --request POST 'http://localhost:3000/api/v1/flowers/11/sightings' \
--header 'Authorization: Bearer <auth token retrieved on login endpoint>' \
--form 'sighting[latitude]="<latitude>"' \
--form 'sighting[longitude]="<longitude>"' \
--form 'sighting[image]=@"<file path>"'
```

### Like sighting

```
curl --location --request POST 'http://localhost:3000/api/v1/flowers/<flower id>/sightings/<sighting id>/likes' \
--header 'Authorization: Bearer <auth token retrieved from login endpoint>' \
--data-raw ''
```

### Remove sighting

```
curl --location --request DELETE 'http://localhost:3000/flowers/<flower id>/sightings/<sighting id>' \
--header 'Authorization: Bearer <auth token retrieved from login endpoint>'
```

### Remove like

```
curl --location --request DELETE 'http://localhost:3000/flowers/<flower_id>/sightings/<sighting id>/likes' \
--header 'Authorization: Bearer <auth token retrieved from login endpoint>'
```
