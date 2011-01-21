module Capistrano::Helpers
  module Prompts

    def ask_for variable, prompt, overwrite=false
      set variable do
        Capistrano::CLI.ui.ask prompt
      end unless exists?(variable) or overwrite
    end

    def ask_for_password variable, prompt, overwrite=false
      set variable do
        Capistrano::CLI.password_prompt prompt
      end unless exists?(variable) or overwrite
    end

  end
end
