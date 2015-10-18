class rjil::jiocloud::jenkins::cloudenvs(
  $envs = {}
) {
  create_resources(rjil::jiocloud::jenkins::cloudenv, $envs)
}
