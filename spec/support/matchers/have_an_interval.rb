RSpec::Matchers.define :have_an_interval do |interval_description, expected_note_string|
  match do |note|
    note.send(interval_description).note_string == expected_note_string
  end

  failure_message_for_should do |note|
  	"Expected #{note.note_string}'s #{interval_description} interval to be #{expected_note_string}"
  end

  description do |note|
  	"have an #{interval_description} interval of #{expected_note_string} for #{note.note_string}"
  end
end
