#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path('../', __FILE__)
require 'app/models/user'
require 'app/controllers/controller'

User.create_table


