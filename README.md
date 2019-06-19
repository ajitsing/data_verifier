# data_verifier

[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/ajitsing/data_verifier/graphs/commit-activity)
[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=102)](https://opensource.org/licenses/MIT)
[![Gem Version](https://badge.fury.io/rb/data_verifier.svg)](https://badge.fury.io/rb/data_verifier)
[![HitCount](http://hits.dwyl.io/ajitsing/data_verifier.svg)](http://hits.dwyl.io/ajitsing/data_verifier)
![Gem Downloads](http://ruby-gem-downloads-badge.herokuapp.com/data_verifier?type=total)
[![Build Status](https://travis-ci.org/ajitsing/data_verifier.svg?branch=master)](https://travis-ci.org/ajitsing/data_verifier)
[![Twitter Follow](https://img.shields.io/twitter/follow/Ajit5ingh.svg?style=social)](https://twitter.com/Ajit5ingh)

There are times when we change the approach of modifying data and want to verify
that the data modified by the new approach is same as the old approach.
This gem is build for such verifications.

## Motivation

In my project, we replicate the data from other systems. There was a requirement where we changed the source of the data
and code to replicate the data to our system. In testing phase we wanted to create a validation sheet,
which can show the difference b/w the data in our system before and after the new source.

## Installation
Add this line to your application's Gemfile:
```ruby
gem 'data_verifier'
```

## Usage
This gem has to be used in two phases:

1. Build Phase: Use this phase to build the baseline of the data before changing the code/approach
2. Verification Phase: Use this phase to verify the new data against the baseline data

#### Config:

```ruby
require 'data_verifier'

QUERIES = {
    users_table: "select * from users where id=100",
    phones_table: "select * from phones where user_id=100",
    addresses_table: "select * from addresses where user_id=100",
}

config = DataVerifier::Config.new do |c|
  c.db_adapter = :oracle
  c.db_user = 'my_db_user'
  c.db_password = 'my_pass'
  c.db_host = 'localhost'
  c.db_name = 'test_db'
  c.db_port = '1521'
  c.data_identifier = 'user_id_100'
  c.queries = QUERIES
end
```

#### Building Baseline Data:

The below code will execute all the queries and store their result in json files.

```ruby
DataVerifier::BaselineBuilder.new
      .with(db1_config)
      .with(db2_config)
      .build
```

#### Verification:

Below code will again execute the queries and will compare it with the baseline data.
After comparision it will create an excel file of the result.

```ruby
DataVerifier::Validator.new("data_sanity_report")
      .validate_using(db1_config)
      .validate_using(db2_config)
      .generate_report
```

#### Result:

<img src="https://github.com/ajitsing/ScreenShots/blob/master/data_verifier/data_verifier_result.png"/>

## License
```license
MIT License

Copyright (c) 2019 Ajit Singh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
