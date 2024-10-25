# frozen_string_literal: true

def current_git_branch
  branch = `git rev-parse --abbrev-ref HEAD 2>/dev/null`.chomp
  $CHILD_STATUS.exitstatus.zero? ? branch : 'no-git'
end

if defined?(Rails)
  short_env_options = {
    'test' => 'test',
    'development' => 'dev',
    'production' => 'prod',
    'staging' => 'stage'
  }
  app_name = Rails.application.class.module_parent_name.underscore.dasherize
  env_color = Rails.env.production? ? :red : :green
  short_env_name = short_env_options[Rails.env]
  env_and_git = "#{short_env_name}/#{current_git_branch}"
  env_name = Rails.env.development? ? env_and_git : short_env_name
  env = Pry::Helpers::Text.send(env_color, env_name)
  description = 'Prompt has to match the rails app name'
else
  app_name = Dir.pwd.split('/').last.to_s
  env = Pry::Helpers::Text.green(current_git_branch)
  description = 'Prompt has to match the current folder name'
end

app = Pry::Helpers::Text.cyan(app_name)

Pry::Prompt.add(:current_app) do |_context, nesting, pry_instance, sep|
  format(
    '[%<in_count>s] %<app>s(%<env>s)%<nesting>s%<separator>s ',
    in_count: pry_instance.input_ring.count,
    app:,
    env:,
    nesting: (nesting.positive? ? ":#{nesting}" : ''),
    separator: sep
  )
end

prompt = Pry::Prompt[:current_app]
procs = [
  proc { |*args| prompt.wait_proc.call(*args).to_s },
  proc { |*args| prompt.incomplete_proc.call(*args).to_s }
]

Pry.config.prompt = Pry::Prompt.new(
  'custom_app_prompt', description, procs
)
