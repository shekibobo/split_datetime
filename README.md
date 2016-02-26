TimeSplitter
============
[![Build Status](https://travis-ci.org/shekibobo/time_splitter.png)](https://travis-ci.org/shekibobo/time_splitter)
[![Gem Version](https://badge.fury.io/rb/time_splitter.png)](http://badge.fury.io/rb/time_splitter)
[![Code Climate](https://codeclimate.com/github/shekibobo/time_splitter.png)](https://codeclimate.com/github/shekibobo/time_splitter)

Setting DateTimes can be a difficult or ugly thing, especially through a web form. Finding a good DatePicker or TimePicker is easy, but getting them to work on both can be difficult. TimeSplitter automatically generates accessors for `date`, `year`, `month`, `day`, `time`, `hour`, and `min` on your datetime or time attributes, making it trivial to use different form inputs to set different parts of a datetime field.

This gem is based on [SplitDatetime](https://github.com/michihuber/split_datetime) by [Michi Huber](https://github.com/michihuber). TimeSplitter improves on the gem, updating for Rails 4, adding `time` accessors, and providing a safer and more consistent default setting.

## Install

### Standalone

`$ gem install time_splitter`

### Gemfile

In your `Gemfile`:

```ruby
gem "time_splitter"
```

After bundling, assuming you have an Event model with a starts_at attribute, add this to your model:

```ruby
class Event < ActiveRecord::Base
  extend TimeSplitter::Accessors
  split_accessor :starts_at
end
```

In your view:

```erb
<%= simple_form_for @event do |f| %>
  <%= f.input :starts_at_date, as: :string, input_html: { class: 'datepicker' } %>
  <%= f.input :starts_at_hour, collection: 0..24 %>
  <%= f.input :starts_at_min, collection: [0, 15, 30, 45] %>
  <%= f.input :starts_at_time, as: :time
  <%= ... %>
<% end %>
```

Add your js datepicker and you're good to go. (Of course, this also works with standard Rails form helpers).

If you are using Rails < 4.0 and/or are not using StrongParameters, you must add `attr_accessible` for any of the split attributes you want to permit mass-assignment. TimeSplitter provides the methods that can be directly accessed, but will not automatically whitelist any of them for mass-assignment.

## Options

By default, the read accessors provided by TimeSplitter are as follows:
```ruby
starts_at_date #=> Date
starts_at_year #=> Fixnum
starts_at_month #=> Fixnum
starts_at_day #=> Fixnum
starts_at_time #=> Time or Timey class used in :default option
starts_at_hour #=> Fixnum
starts_at_min  #=> Fixnum
```

You can override the default read format for date and time if you so choose, though doing so may not work well with certain form input types.

```ruby
split_accessor :starts_at, date_format: "%D", time_format: "%I:%M%p"

starts_at_date #=> String "2013-10-13"
starts_at_time #=> String "01:44PM"
```

See `Time#strftime` for formats.

You can specify multiple datetime fields to split:

```ruby
split_accessor :starts_at, :ends_at, :expires_at, format: "%D"
```

You can specify a default timey object to write. If `starts_at` is `nil`, which it would be at the time of a `new` or `create` call, TimeSplitter will use the default value as the basepoint for modification.

```ruby
split_accessor :starts_at, default: -> { DateTime.current }

# model = Model.new(starts_at_time: '09:00')
# model.starts_at
# => Thu, 10 Oct 2013 09:00:00 -0400 # DateTime
```

The default time object is `Time.new(0, 1, 1, 0, 0, 0, '+00:00')`.

Note that TimeSplitter does not handle seconds at this time, and from testing it appears they are set to zero when modifying them.

