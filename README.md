music
=====

The *music* gem provides a means on calculating notes and chords.

Examples:
---------

Creating notes:

    note = Note.new(698.46) # Creates a note object with the frequency 698.46
    note = Note.new('F#6') # Creates an F sharp note in the 6th octave

Comparing notes:

    Note.new(698.46) < Note.new(1975.53)    # => true
    Note.new(698.46) == Note.new('F5')      # => true

Converting from frequency to note string and vice versa:

    Note.new(698.46).note_string    # => 'F5'
    Note.new('Bb3').frequency       # => 233.08

Find how many semitones two notes are apart:

    Note.note_distance('A4', 'A#4')     # => 1
    Note.note_distance('B1', 'F1')      # => -6
    Note.note_distance('G#1', 'Ab1')    # => 0

Adjust frequencies by semitones:

    Note.frequency_adjustment(440.0, 15)    # => 1046.50

Create chords:

    chord = Chord.new(['C4', 'E4', 'G4'])   # Create a C major chord

Describe chords:

    Chord.new(['C4', 'Eb4', 'Gb4'])     # => ['C', :diminished]

*For further usage, see the examples in the spec files*

TODOs:
======

 * Use the term musical term 'interval' instead of 'distance' in code

Contributing to music
=====================

Contributions are welcome.  Check out the issues list and feel free to fork and make a pull request if you have any fixes/additions.

Copyright
=========

Copyright (c) 2012 Brian Underwood. See LICENSE.txt for
further details.

