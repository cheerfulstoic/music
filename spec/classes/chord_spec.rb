require 'spec_helper'

describe Music::Chord do
  before :all do
    @standard_tuning_notes = [Note.new('E2'), Note.new('A2'), Note.new('D3'), Note.new('G3'), Note.new('B3'), Note.new('E4')]
  end

  describe '#new(notes)' do
    it 'should take an array of Note objects' do
      Chord.new(@standard_tuning_notes)
    end

    it 'should take an array of note strings' do
      Chord.new(@standard_tuning_notes.collect(&:note_string))
    end

    it 'should sort the notes by frequency' do
      Chord.new(['A2', 'E2']).note_strings.should == ['E2', 'A2']
    end
  end

  describe '#note_strings' do
    it 'should return an array of note strings' do
      chord = Chord.new(@standard_tuning_notes)

      chord.note_strings.should == @standard_tuning_notes.collect(&:note_string)
    end
  end

  describe '#describe' do
    describe 'major chords' do
      it 'should recognize C major' do
        Chord.new(['C4', 'E4', 'G4']).describe.should == ['C', :major]
      end
    end

    describe 'minor chords' do
      it 'should recognize C minor' do
        Chord.new(['C4', 'Eb4', 'G4']).describe.should == ['C', :minor]
      end
    end

    describe 'diminished chords' do
      it 'should recognize C diminished' do
        Chord.new(['C4', 'Eb4', 'Gb4']).describe.should == ['C', :diminished]
      end
    end

    describe 'augmented chords' do
      it 'should recognize C augmented' do
        Chord.new(['C4', 'E4', 'G#4']).describe.should == ['C', :augmented]
      end
    end
  end
end