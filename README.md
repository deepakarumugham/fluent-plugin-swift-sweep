# fluent-plugin-swift-sweep


Fluentd plugin to read data from files and move it Swift object storage as is.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-swift-sweep'
```

Or install it yourself as:

    $ gem install fluent-plugin-swift-sweep

## Basic Behavior

Assume your files are inside `/tmp/test` directory as

```
tmp/test
├── core.files1.log
├── core.files2.log
└── core.files2.log
```



This plugin watches the directory (`file_path_with_glob tmp/test/*.log`), and reads the contents and sends the files to swift storage and removes the file, after sending them to swift.

The files will be moved to swift container as:
tmp/test/core.files1.log
tmp/test/core.files2.log
tmp/test/core.files3.log

## Configuration

```
<source>
  type swift_swwep

  # Required. process files that match this pattern using glob.
  file_path_with_glob /tmp/imp/*.log

  # Required. Authentication URL 
  auth_url <Authentication url>

  # Required. Authenticated User Name
  auth_user <User name>

  # Required. Password
  auth_api_key <Password>

  # Required. The name of the openstack tenant
  auth_tenant <Openstack Tenant>

  # Required. The name of the swift container
  swift_container <Container Name>

  ssl_verify false
</source>
```

## ChangeLog

[CHANGELOG.md](CHANGELOG.md)

## Warning
* This plugin supports fluentd from v0.12.33

## Contributing

1. Fork it ( https://github.com/deepakarumugham/fluent-plugin-swift-sweep/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
