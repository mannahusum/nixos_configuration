{ users, ... }:
{
  imports =
    [ # ...
      <musnix>
    ];

    musnix = {
      enable = true;
      alsaSeq.enable = true;
      soundcardPciId = "00:1b.0";
      kernel = {
        optimize = true;
      };
    };

    sound = {
      enable = true;
    };
}

