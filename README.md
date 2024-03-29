# has-many-with-set

### A smarter way of doing many-to-many relationships in Ruby On Rails.

## Introduction

*Update: Now works with Rails 5*

*This technique is explained with more detail in this [post](https://ebobby.org/2012/11/11/Using-sets-for-many-to-many-relationships/).*

Rails has two ways to model many-to-many relationships: `has_and_belongs_to_many` and `has_many :through`, this gem introduces a third one: `has_many_with_set`.

`has_many_with_set` is equivalent to `has_and_belongs_to_many` in functionality. It works only when you do not want information about a relationship but the relationship itself, behind the curtains though, they do not work anything alike, `has_many_with_set` is far more efficient in terms of data size as it reduces the redundancy that occurs in a normal many-to-many relationships when the cardinality is low, that is, the same combination occurs many times. For example, in a blog application, when many posts share the same tags.

## How so?

The regular way of doing many-to-many relationships is using a join table to relate two tables, both ways of doing it in Ruby On Rails use this method, the only difference is the degree of control they give you on the "intermediary" table, one hides it from you (which is nice) and the other allows you to put more data in it besides the relationship, use validations, callbacks, etc.

The _join_ table model is a very redundant way of storing these relationships if the same combination happens more than once because you have to create the same amount rows in the join table each time you save this combination for each different _parent_.

For example:

```
Tag.create(:name => 'programming')
Tag.create(:name => 'open source')
Tag.create(:name => 'startups')
Tag.create(:name => 'ruby')
Tag.create(:name => 'development')

tags = Tag.all

1000.times do
  a = Article.new(:title => "Buzzword about buzzwords!",
                  :body => "Lorem ipsum")

  a.tags = tags.sample(rand(tags.size + 1))

  a.save
end

ArticlesTags = Class.new(ApplicationRecord)
ArticlesTags.count # this class doesn't exist by default,
                   # I had to create it by hand for the example.
=> 1932
```

So we create five tags, and we create 1000 articles with a random combination of tags, not surprisingly, our join table has plenty of rows to represent all the relationships between our articles and their tags, if this were to behave linearly, if we had 1,000,000 articles we would have 1,932,000 rows just to represent the relationship.

This example  (albeit a bit unrealistic) shows how redundant this is, even though we are using the same combination of tags over and over again we get more and more rows, if we are speaking about thousands it is not a big problem but when your databases grow to the hundreds of thousands or the millions, stuff like this starts to matter.

This is what this gem fixes, it makes sure that when you create a combination of items it is unique and it gets used as many times as its needed when requested again, like a *set*.

`has-many-with-set` is here to help.

## Installation

*Rails 5.x*

To use it, add it to your Gemfile:

`gem 'has-many-with-set'`

That's pretty much it!

## Usage

To to use `has-many-with-set` to relate two already existing models you have to create the underlying tables that are going to be used by it, this is very easily done by generating a migration for them:

`rails generate has_many_with_set:migration PARENT CHILD`

And add the relationship to your parent model:

```
class Parent < ApplicationRecord
  has_many_with_set :children
end
```

And that's it! You can start using it in your application. This can be done for as many models as you want, (you have to create migrations for all combinations!) you can even use multiple sets to relate different data to the same parent model (like Authors and Tags for your Articles).

## Example

Using our previous example:

```
rails g model Article title:string body:text`

rails g model Tag name:string

rails g has_many_with_set:migration Article Tag
      create  db/migrate/20121106063326_create_articles_tags_set.rb

class Article < ApplicationRecord
  has_many_with_set :tags   # <--- key part!
end

Tag.create(:name => 'programming')
Tag.create(:name => 'open source')
Tag.create(:name => 'startups')
Tag.create(:name => 'ruby')
Tag.create(:name => 'development')

tags = Tag.all

1000.times do
  a = Article.new(:title => "Buzzword about buzzwords!",
                  :body => "Lorem ipsum")

  a.tags = tags.sample(rand(tags.size + 1))

  a.save
end

ArticlesTagsSetsTag = Class.new(ApplicationRecord)
ArticlesTagsSetsTag.count # this class doesn't exist by default,
                          # I had to create it by hand for the example.
=> 80

Article.first.tags
=> [#<Tag id: 1, name: "programming", ...>]

Article.last.tags
=> [#<Tag id: 1, name: "programming", ...>, #<Tag id: 5, name: "development", ...]

# The child model can also see to which parent models it relates to

Tag.first.articles.size
=> 503

Tag.first.articles.first
=> #<Article id: 2, title: "Buzzword about buzzwords!", ..>

```

Same example as before, just now using `has_many_with_set`. We get the impressive number of 80 rows to represent the same information that we had before with thousands of rows (roughly the same, since we use random combinations is not _exactly_ the same article/tag layout).

The funny thing in this particular example, is that since we have only five tags, there are only 32 possible ways to combine five tags together, these 32 combinations amount to 80 rows in our relationship table.... that is, even if we had a million articles we would still have the same 80 rows to represent our relationships, we don't need to create any more rows!!

## Final remarks

Please keep in mind that `has-many-with-set` is not without some caveats:

* It can only be used when you do not need to put extra information in the relationships rows since they are shared among many parents.
* It is only effective when there is a high natural redundancy in your data, that is, when many sets can be shared among many parents.
* Although the retrieval queries are the same as with regular `has_and_belongs_to_many` and have no extra cost, it does have a tiny bit of extra cost when saving or updating since we have to find or create a suitable set before actually saving the parent record to the database. This cost is probably negligible as opposed to writing all the time, but I can't say it's free.

This is one humble attempt to help make Ruby On Rails a bit more useful with large data sets and applications, I hope you enjoy it and is useful to you, please email me with comments or suggestions (or even code!).

## Author

* Francisco Soto <ebobby@ebobby.org>

Copyright © 2012 Francisco Soto (http://ebobby.org) released under the MIT license.
