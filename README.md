# ocranizer

Simple fast CLI organizer.

## Installation

First `make` or `shards build pim`. Next you need to copy binary file into
one of directories in `PATH` variable.

You can use `make install` or `sudo cp -vn bin/pim /usr/bin`.

Note: I'm not Mac user so this can be not Mac (or Unix) compatible because of
user home path.

## Usage

### Main types - entities

`Event` is a time range when something occurs. It's described by time and the time
defines when `Event` occurs.

`Todo` is a task which must be completed. It can be described by time. `Todo`
can have (but not need to have) deadline - `time_to` and can be started after
time point - `time_to`.

`Event` and `Todo` is an `Entity`.

### Command parameters styles

#### Destructive actions

Most destructive commands are uppercase. For example if you want to search an
`Event` you use `pim -e`, but if you want to add you should use uppercase `E`
like `pim -E`.

#### Parameters

There is predefined list of possible parameters. They can be used to
**filter**, **create**, **update** and **delete** depends on command.

Theese parameters are:

* `-n` or `--name` - name/title
* `-i` or `--id` - unique identifier of an `Entity`
* `-a` or `--from` - start time
* `-z` or `--to` - end time
* `-d` or `--day` - only for filtering for particular day
* `-p` or `--place` - place
* `-c` or `--category` - category, just one `String` like `work`, `private`
* `-g` or `--tags` - tags, `Array(String)` but you should type them in one `String` separated with coma `,`
* `-c` or `--desc` - longer description of `Entity`, totally optional
* `-u` or `--user` - other people `Entities`
* `-b` or `--url` - external http link for `Entity`

#### What is an User

Imagine you have friend you often travel with. You can add his blocking events
here. You can later get his all events and know when he is available.

#### Filter params

Parameters described above behaves differently when used in **create** and
**filter**.

* `-n` or `--name` - substring, ignore case
* `-i` or `--id` - substring, ignore case
* `-a` or `--from` - filter within range
* `-z` or `--to` - filter within range
* `-d` or `--day` - filter overlapping day
* `-p` or `--place` - substring, ignore case
* `-c` or `--category` - exact, case
* `-g` or `--tags` - exact, case
* `-c` or `--desc` - substring, ignore case
* `-b` or `--url` - substring, ignore case
* `-u` or `--user` - described below

#### User filter

* `-u ""` - default filter only own `Entity`
* `-u "rest"` - filter only other (not blank) users
* `-u "all"` - show all: self and other
* `-u "joe"` - show only `joe` entities

#### Create params

To create `Entity` you need to specify enough required parameters.
`Todo` require only `name` but `Event` require `name`, `time_from` and `time_to`.

Example: `pim -T "Clean room"`

You can specify more information (except the `id` which is generated automatically).

Example: `pim -T "Clean room" -c "apartment"`

### Add `Event`

`pim -E "Doctor appointment" -a "2017-02-05 12:00" -z "1 hour" -g "doctor" -c "appointment"`

Result:

```
Doctor appointment
2017-02-05 12:00 -> 2017-02-05 13:00
category: appointment
tags: doctor
Id: 20170124131927368
```

Everything is stored at `~/.ocranizer.yml`

### HTML output

Just add `-H` and it will generate HTML calendar and open it in default browser.
Calendar file is located at `~/.ocranizer.yml.html`.

### Help

`pim -h` will tell you about all possible parameters.

### Human time form

Please check [here](https://github.com/akwiatkowski/ocranizer/blob/master/spec/ocra_time_spec.cr)
for more details.

You can use absolute values like:

* `2017-10-10` for full day,
* `10-10` for full day with current or next year (no past time)
* `2017-10-10 12:40` for exact,
* `13:40` for current day

or relative values like:

* `1 week` - 1 week from now or event's time from
* `prev 1 hour` - 1 hour before

## Development

* [x] Not allow create entity when `time_from` > `time_to`
* [ ] `time_to` if typed as hours uses date from `time_from`
* [ ] Interpret fullday as 0:00 - 23:59
* [ ] Show entity id at details
* [ ] TEST, TEST, TEST!!!
* [ ] Test command parser
* [x] Delete action
* [ ] Postpone - update but easier
* [ ] Add own search configuration like macro, ex: `work_today` show all with `work` category and proper time ranges, `incoming` with entities till `2 days`
* [x] Update `id` to make it always unique for `Event` and `Todo`
* [x] Add events, todos using command line interface
* [x] Inteligent time parser: full, partial, words like tommorow, +1 day, +1 week
* [ ] List of upcoming events
* [x] Edit existing events
* [ ] Integrare output with [remind](https://wiki.archlinux.org/index.php/Remind )
* [x] Render HTML output
* [x] Saving with backup
* [ ] Add limit filter


## Contributing

1. Fork it ( https://github.com/akwiatkowski/ocranizer/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [akwiatkowski](https://github.com/akwiatkowski) Aleksander Kwiatkowski - creator, maintainer
