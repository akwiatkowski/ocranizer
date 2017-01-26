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

TODO: Delete is not implemented yet

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

#### What is User

Imagine you have friend you often travel with. You can add his blocking events
here. You can later get his all events and know when he is available.

TODO: Ex: Allow to add `Event` when other user has free weekend

#### Filter params

Parameters described above behaves differently when used in **create** and
**filter**.



#### Create params


### Add `Event`

`pim -E "Doctor appointment" -a "2017-02-05 12:00" -z "1 hour" -g "doctor" -c "appointment"`

### List

`pim -i` shows incoming events

### Add



The result will be already added at `~/.ocranizer.yml`

```
Doctor appointment
2017-02-05 12:00 -> 2017-02-05 13:00
category: appointment
tags: doctor
Id: 20170124131927368
```

If you use `pim -i` you will get summary of all incoming events sorted by time:

```
Doctor appointment : 2017-02-05 12:00 - 2017-02-05 13:00 [20170124131927368] appointment, doctor
```

### Help

`pim -h` will tell you about params

### Human time form

Please check [here](https://github.com/akwiatkowski/ocranizer/blob/master/spec/ocra_time_spec.cr)
for details.

You can use absolute values like:

* `2017-10-10` for full day,
* `2017-10-10 12:40` for exact,
* `13:40` for current day

or relative values like:

* `1 week` - 1 week from now or event's time from
* `prev 1 hour` - 1 hour before


## Development

* [ ] Delete action
* [ ] Postpone - update but easier
* [ ] Add own search configuration like macro, ex: `work_today` show all with `work` category and proper time ranges
* [ ] When adding `Entity`
* [ ] Update `id` to make it always unique for `Event` and `Todo`



* [ ] Add events, todos using command line interface
* [ ] Inteligent time parser: full, partial, words like tommorow, +1 day, +1 week
* [ ] List of upcoming events
* [ ] Edit existing events
* [ ] Postpone
* [ ] Integrare output with [remind](https://wiki.archlinux.org/index.php/Remind )
* [ ] Render HTML output
* [ ] CLI add
* [ ] commad line (non-interactive): add, edit, postpone, delete
* [ ] Saving with backup

## Contributing

1. Fork it ( https://github.com/akwiatkowski/ocranizer/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [akwiatkowski](https://github.com/akwiatkowski) Aleksander Kwiatkowski - creator, maintainer
