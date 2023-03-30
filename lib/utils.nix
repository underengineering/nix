{ lib }:
with lib;
{
  # Enable a module if attribute exists and is true
  enableModule = config: module: path:
    if (attrByPath path false config)
    then [ module ]
    else [{ }];
}
