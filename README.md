# ocranizer

Simple fast CLI organizer.

## Installation

First `make` or `shards build pim`. Next you need to copy binary file into
one of directories in `PATH` variable.

You can use `make install` or `sudo cp -vn bin/pim /usr/bin`.

Note: I'm not Mac user so this can be not Mac (or Unix) compatible because of
user home path.

## Usage

### List

`pim -i` shows incoming events

### Add

`pim -a "Doctor appointment" -f "2017-02-05 12:00" -t "1 hour" -g "doctor" -c "appointment"`

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
