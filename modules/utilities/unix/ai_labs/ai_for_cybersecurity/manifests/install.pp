# Installs the AI-for-Cybersecurity notebooks at a fixed commit into each account's home directory.
class ai_for_cybersecurity::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $accounts = $secgen_parameters['accounts'] ? {
    undef   => [],
    default => $secgen_parameters['accounts'],
  }

  ::python_ml_env::notebook_repo { 'AI-for-Cybersecurity':
    repo_url => $secgen_parameters['repo_url'][0],
    commit   => $secgen_parameters['commit'][0],
    accounts => $accounts,
  }
}
