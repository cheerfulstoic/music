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
    describe "triads" do
      it 'should recognize C major' do
        Chord.new(['C4', 'E4', 'G4']).describe.should == ['C', :major]
      end

      it 'should recognize C minor' do
        Chord.new(['C4', 'Eb4', 'G4']).describe.should == ['C', :minor]
      end

      it 'should recognize C diminished' do
        Chord.new(['C4', 'Eb4', 'Gb4']).describe.should == ['C', :diminished]
      end
      it 'should recognize C augmented' do
        Chord.new(['C4', 'E4', 'G#4']).describe.should == ['C', :augmented]
      end
    end
    describe "seven chords" do
      it 'should recognize Cmaj7' do
        Chord.new(['C4', 'E4', 'G4', 'B4']).describe.should == ['C', :major_7]
      end
      it 'should recognize Cmin7' do
        Chord.new(['C4', 'Eb4', 'G4', 'Bb4']).describe.should == ['C', :minor_7]
      end
      it 'should recognize Cdim7' do
        Chord.new(['C4', 'Eb4', 'Gb4', 'A4']).describe.should == ['C', :diminished_7]
      end
      it 'should recognize Cmin7b5' do
        Chord.new(['C4', 'Eb4', 'Gb4', 'Bb4']).describe.should == ['C', :half_diminished_7]
      end
      it 'should recognize Caug7' do
        Chord.new(['C4', 'E4', 'G#4', 'Bb4']).describe.should == ['C', :augmented_7]
      end
    end
  end
end