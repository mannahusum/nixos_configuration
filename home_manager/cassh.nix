{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  itivHosts = {
    "bck" = {
      hostname = "bck.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRcGmEjgew+IWvw5eySjzA1fX4l5NYHHL+Z3GQsGFFp1LggV/tjGrNWIrSDFILR0nIYrLrNNTGkopkfAoK70USMtun0HI/FKH7l+hqIhm0BZg1pDGoqiDPkqUO4A59QJH07f10hjruzs+JRegNWX8P1wQ4ZJK7FXT//X1QUq9CabfH6vdUxXCgtCmidkjP2iy0nDs3CLga3K82TR7ONszcb3a6J1SwaAaLY8xD+RG6kfKaBknuDCE/40M4jCDmW21qIlXnR73B7+fGnKNDa1OUkOCfWWlUy1WUYmFb5KdPgnYVu2ZLLlwd0S6FqiSmwJCCm7TnnR/Q9bJ0T+EZ88X1T6cgsMY3vHhyKK8mdzu4yDWcmYWauxEm5zLaJTmTBbce4AJanEz3/UW5lBwHtw98UlZ5eZc69PtD3UktJ0I4+0FCCRfzX1yo5zqKgWfkAOGebLvXiEdIFs0c43UHpluJXCHLfxSaGDnkhJPkhT7GK0FWIx1ABVTnIV2HBG8GG/8="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHpnGIGBOdh1PYawWguQoHy6bG/gp+z5RNXQGwvbDtICedH7xsqBOq8EJ0i1PLGTV1kmcPFID5zzO0hRsAXhZ7g="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIILrMy+pMj1qBV1h30mi7lC/3uJlcZPEepAk+HIyqGca"
      ];
      overrides = {
        user = "root";
      };
      gpgSocket = null;
    };
    "cbm-vm1" = {
      hostname = "itiv-cbm-vm1.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCpuLQd87mVzqVjIg/6wR6XijAPo4hWWPqo45e3TD/0rHSgWe+4ExZx2mUvcuaZiefewf41b/O40lpoksbqtpXZNaUXl/tLthx+CneZS/tCNiPR0zFJVy58NTNgxSQ+Bf7WvHRG43jVnpwZ0mFlOGcvG/Kld70lRqq21cESrkk70RVAhypzfqENg3sOiAnD3AKfFaz9K1h6DHMT8TDj64ttMdSrYgJnJ/u/UdxyaUDu+ESCGD5uYN74mjtpsxHm+EWvPrMZXNn9lP3xdD0ujnkK8MEB1G8J4iDuKtLUygL4pjwc86zUIEbsMw74DrlN3dvMiPtcYwKA7y9CTqgxtVFbaSax/VT55C/OWwRqGESHrKM6J13HnoNvfzW7ayvXIpLSu/FXSOKj56A9G9rimk6+sBdrouYdS7X8w7Y2ZVKUejeQtD5rpkiRyci3UY4L1RqP8Ts9imDv9rgO7E5qHLF9nylW8I71/7D4n4Op8hisS4yHOQ/PAydrzBZcuQBWLWGKigJkrEv0fu3TINl3CRPMN+FgAHUP3I+wEQVzlPbYnw5T8/3vivzpg0RLEmjXc1bsqTDKxMaIk65LiDFtOUN1XCvZcbH9ebjj7oeJ2mU3xg8U6JjDyeBicoczyNbzXBhRT6/iEtuXBn5oY1o19mb31rcriOq0gOJGI7qJOF2aow=="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPH77EjF3cq/hlkW8bqq/FbOgnu7RlFhNaGUwOn9bbzw"
      ];
      gpgSocket = null;
      overrides = {
        user = "localadmin";
      };
    };
    "docker" = {
      hostname = "docker.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCUoiIO5UjcDaaj6NsliWnPSaG9lxpiWBauvdhA3UHc9pfhUVy9H1Xmsv6VsLlOCEOvDu/jUCJUZkh9CWtg0/QgcYxpNpnt+XYiEi3HVsgTz8cTl0WkPeE6VsFZfeQ9jDH39NpWNxgCaHPzjI3bCxLtU7aJYBf7yfgs1xMndvZDeD8/Pma0BDeKWFzPLDV9sIiA1qsiI/0CMqtskZ+W+JcAdCGXfhp+9XQ1j1oFQp3hpXUhMEEi0akiVLpZib5Qd+gOMbeTo3nVqTHGVs5Zs7tS404tS6/Kc3wkIIVI7tsNidFtFUC7kkyYl/T/UtW5zsDTFR++4SZ5JMacZolzVHzUDet+42p8kvOww99qYktfoMnmrwm1hXITKISbHmhAobFObuq0owzybVo5+abZl6hkrQfY5zfGH7rvGPUWTsU6QBksL9pXD4DgZogEfvG4L9NqphPUsbIOi1mg2fzTDM5fgH/GveYaBlhJvFn0ZIPB48xXaYOP8qMjfL2jHG/WO2M="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEGf35sy3cT+e3PXBFsJej4fiGaflYPZJ53OqNmySSJ3u1JExbDKdoH7eK2GyqUEBDI3S+xLzPBZJtv1zs7MAVI="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNLZW59eQD+aC7IKmrnx0EXyk8O2iGysoawWFSkQe4H"
      ];
      gpgSocket = null;
      overrides = {
        user = "core";
      };
    };
    "gitlab" = {
      hostname = "gitlab.itiv.kit.edu";
      hostkeys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHugXnN8Abq0+XxTHyyC5ivWeBGrT2Du1iXhLhvsRndsYtvk+XSCPORhVJ3hZLK0xOetLW5pRFDht5OsNBYIKsc="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDA4QVItjW8J4eFSZyKo6XTe3+Hf7712cMQ/TBfomNzhraZJbqSnKj8zavCk7AMngM8SQJW8qupTtwu7BlgFvOvGEjzhCd0TzyUeLXk3L1YFk2/GG1OaR2levRtB0knxGxmvNaS6FP8HcxMsRLDQ6l2jnKq+Hh3fns1yVTBoRv11Kb+HYNbiFCZpDbwA+NdD4Xa6V3jgnkWRTQi3nrvuzUqNbf1QDJ5uFOyfY6J7liU7DVROMFiwuHY6+8vVLhqx1pJNBRcRYhds6zFMC/SLYM9BPJtlSja9LqvAZjEGdrmHaRp221cNHOJ12/1CLUyyi6RK3I9MEQekFo6g1WY7lvB"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILMn85MtEvgnlVxfU80QisiUGM3ClXiYqdlE1IAA/39f"
      ];
      overrides = {
        user = "root";
        ServerAliveInterval = 15;
        ServerAliveCountMax = 3;
      };
      gpgSocket = null;
    };
    "gpu1" = {
      hostname = "gpu1.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8I1DFFqUj+LGpTUZd0SPyfUfpOPJNYP+U9fhd5biiqNq1YxCE1V+DHHNWTSh+x5W5AAeMeWC9HAk9p/+IwoKW3E2t2eP7Q6y9z805maQT++v7wvxwCVY+Fvk4luq3hnZ2dcTLf3kfHwlBzkLxvlkUiB22dwHk4B83Wt6EzfKexBFWoPaIKRh812kmlUOvbV+6R2pbOY/nDgH0yy4IyS7OUuLjP+jsshe00PS3I4n+l5f0oOpyarOU1x8ZY42kpX/gHhqiIIUCZB8ZmUSU7lUz5vRoBWDW5gFHN11qp5w5Y17NYS51JAt+HNhjJqPt6AzjlY72xb0DTKA6IJ+iLjmEM62/yMeukQuEYd78jt/rPigZi2GtO1hpM4czkO3g2D/mPoljMqeLW5u9EsKAb+ssQMg/dSRB6yIZCb6oyxaINd8NFDkM+p3K4qz03Yb3g8i70jrj3n5pZjJRMl6uzJ9Bjn6IEThux8Ihr7ueF8lA4QWs8YcKSyKqXBQDmiPZvcc="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEbwEsBwxgYds4bLUg9lZXHzp1hlcicljzEpid7aCGT7JNVT9bI657umdMUHVdgh+b2ep0BHTm5yU13jzlSvs48="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRJCI+M2HxfjjTjEe643aSkDX9r5GBvm3Seyn+J/d/c"
      ];
      gpgSocket = null;
    };
    "gpu2" = {
      hostname = "gpu2.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtaRUrCiZd3LL20Mg48zyaP5sfQo51XJ979W+IK4Y4aLm0FaJL9Y1PSywKuueM7qMg7ohym23Jvp3fxpJLCQegSilR7dz+jsysgGG0i070Z+qa82zSQuT9+yeod+0DfGqU6t/XkElQ7jiolY7Kv55xYA3XFGxFT0jy0lQb+NHIbD8jUu0dXITuyRxyo6w8irVrW7UhupX3mz1dNaFgxnWEe1/r7Xf6cQEBYdguG4ABcT2ij7Dud6vt7maY4oWnIp3QW7MKz0YOfM1K9rs0xVmTVZWzyOkeFuXs8DtGeN2gQU8YeHni87+8pqfUHMnPqkx1ab2ve/rhhYt7zGmbX7xH2R9IJAgxd1rwfxMXWPfIHYpIpfF4vcmOFGntXyDEuyiGld/XgwSHdfuFQv/EE7pSwPq3PP1n/bd28KnKuxwUUeyuAWV65DqgP4ktl9L5D3VZUKm2nVysHVtd6GTSJafMhtDBlAtAi7KcWagrnL/YOxNkZftuKkMXr3iSSmTGYAE="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHllP4h5fInsiO8Jj2leJmc/F5xgk2TuybRwbbRC/BGx9neUSx9uwW0oA6DpYyVttVGoHDeog9HShVFmmpK1kZE="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEuW4fjAtNiQGgh+lH9kcL1ddZH2GOMaHA6V5k2qom1q"
      ];
      gpgSocket = null;
    };
    "hdd1" = {
      hostname = "hdd1.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuaEpX0fl7yPEtnZ/LNzqNkE7WveX2KTDkVaiDk9YTIhKFE3omMUpYus/3/CkxHHS2+0n1Htr3rS9Pa7RituxWga8CqWaJOffDeqBn/cLnu/HAzE7q6/RU/QFEp4+4AcwAE0DfzzMDmbyyzRz07h1rkbs1GI6JjIf2MV/nTKc0wst1hlvebYHB+v6a4UsGy/nrxxDefBZ7FU+xz/VBHPCn36pBBcdoyl9sCZz9ZNr+GNHC5vt1zSxS3i7vAitIdg4MCmlKLDE3pFC5zvJIPteWeoG1Z3yaOc5+pN9H51fvZoMyWuBzl3S05zHEAs18+rbT/fOP1wAvcvRa9g33DVowGEYL2OiHMm0Nq/GX5ZiI1r3e/p+Bk8UbnW+/SXd+hNrrFPCqOoaAvzsCjddKaE/elzqVOOr6sqwLQ19P/rpupKxOSkVk+EMjn84g1Nk/PBKHyQhnIBAsQQos3vaR+w31NWLZymBDo5ib89xL64mWPQftxqmljuglOb1WauRk2Xs="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBF8RGZh0qAFM21ElmjHiM/X0b6zJ8bW39nQCAz16Gn6YW4gV5O+Wg2gNM7RmdQOegTRgUMbU8N4F/tVjGRdOgBs="
      ];
      gpgSocket = null;
      overrides = {
        user = "root";
      };
    };
    "hdd2" = {
      hostname = "hdd2.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdE5YYEENIxbOQKkrgkqGZN6ZGUXnBd/JKDPw1tLLcmn11BZn8b6mqhnM43zQ8AmW0ZhH0WLaLwoVN6GVp51I3ArhKIR/xj62B2l76dDIANJYXys9rpaY7nw84cJp+sBIQXGDrs6UfKsb4G0NEQDU0hMiNtfecqZyKvycANoql9v6rRPHH9sFlT1AboFKigiLO1VRe1vqFiWE5PZtJEqDs9I573DSYKQGKjK5ewPBUerzcmHN2tcO54gyaTL226hh/JqthDhxcxeE4kFDiA0uMhIw39htPYxmNgkl41F/ttsIYX5N0FFD4m9yJiTvfvdp9jdZSFGRF6+ijKF1Y6TxWelJdINeHitHs1o4hM4drKHSdP8trsYU1u9haKdzvUsDRNN80633t7Qx7N80tRD/d+tM11faeUWYWTJaWKZUSZptOXjU7ymYZaa0DmJdr4H/cveScf0r0AC/7a118sokTkYNtjmqymrX+w30TizcG/3BrelDfyHPVbIh6MXgvvAk="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJPZODdj0eEd2JNgnzhf3zJ1NjWY2vZiRtUgD4mZxgXnQ468KkLVb5Gagsa9yEcBmLdqquxLRyG51tOcqvkoi+U="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILtY+cUjmwKGTn6O/4cvtHxEJolNdLjqtgn2+eU9Sf4d"
      ];
      gpgSocket = null;
      overrides = {
        user = "root";
      };
    };
    "invasicrgb" = {
      hostname = "invasicrgb.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/8ICBGMdZHjo+EskpI2DzR9tAzjwf8bsDWY6MZGepwnpBHV5QYO1keqWKsj6Nj8uQkxWlcLvxpVefZy78Nu19oN5GCOoft4lncWgzZaJnvEsTgX3ibPu20T94U/vcQV6m/nPY1z07gAB4I/uVjUYMz6ixKFXT5m/7XpYlqrbW4okqq+FS8tvPqbfGVnwUER3Hw91BIbn2yUBsHJjgKmtL7qesn16S6guzqRajB61DQP00cAQ2hr8Vk8CiQaWbEEBA5ZrxslvSHRdwH1+n9x9d2A4qDNEICtT55/WpYWfuNOtTY6BJ5mg5zrRedI8DpApQoL/p1/m+73TIndRqa1ul"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFnzWN8URgpQ5djzqj3IaGuJd5Btd89vt91Y2DuL9c3hGz+ZMn/tyjW7vf9csHiHk71N1m0JZ2v5UT9BW0NFbh8="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBqpI8cOjPSEj/s4YDquy6eUfw2FhUkib8YfyOhnfRFP"
      ];
      gpgSocket = null;
    };
    "itiv-veins" = {
      hostname = "itiv-veins.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDE46hcgz711H/ZbwU6hzpwHT2BB4hbkI9P02tNtd7WHUJhEUsYqHpqSemwZ+cKwUlewDybDSxRFlhV8XnyjxAtkoxgA30XpHJIkW4N3/qU6c/kCbS36iN2jA7McptYhousmP6b2/J86l40jA7/6/gByvPqmJduaRntcXZ1nv6CS1aWbJ/5+AcjsxovoZc9fxA2iUvIlpa/f9EOfqnDDL6yYU0jzsaB5f6Re+ILpf7KvwoVZSQ0nXfWxlvyjBnatvZ2BaFLHhqsjwwMBbgVomQHlU5/oQzhiyh2Xz3qjQFFxB6hbL4jpYWqkunLX+R1zdIyUI5RkVBKGMtxV1ekaBxx6oNJfo1vMYLXR3NC0vBwVNq97+LIwA+apInuK8vBcIHVMoiI7fZGva1JLZqTT8i0V98mTvZq79jQTFI9nP9+LU0uWjKkJfIPw1LtZoRNbi/cPiU9Fdp2vcliShivKVAmubaHHaD+8g0PCxIleHLXdzqz1lnJM7qxAnXjmL2YNfc="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDIetYHAioAM3tUzz3bKkNtj9/9+O5kJPDGZLfOhb6sqcdBb2t0lQ2uhqMC7a3TQ5XbZjuDTYDC0bLoRLpvfrAM="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBiWu09snBBaHrgAmutLoXUKvWzHLB23PdN3KdtgDnwX"
      ];
      overrides = {
        user = "root";
      };
      gpgSocket = null;
    };
    "itiv-foyerscreen2" = {
      hostname = "itiv-foyerscreen2.itiv.kit.edu";
      hostkeys = [
        "itiv-foyerscreen2.itiv.kit.edu ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD57T9cLviQa82CSUi+fRJub7UdzsQyfzijFZJYYmrHDPC528Wf3uXAukMIZtzSe0tt0Vk01zA9JdQycJY3YNsRKatyaLbZ0zvoSqI2wdYc9cJcDu1RNUAPAIn3/J/RQlTa58YeK8G+9KIswUyBdCF8jVy/t31VpOU9huuhmmoeA0e6Gyi0dmxpy9mxS2w4xp79iNzPa4mHXM9w5Unui8Bl9swN6by1Nh738+wjWXVQ/q/DxQzTC+39fmeJheUisuKAi4ZpOACzkNUlhn00FYnLHz5KGWMGXgh/gahxaDkDP9m3dZnIYF8DqZrrM2NL4AA1nT24h3t3K8w/ZEQjd/zA/EYFVwAYVioPqwGWeJGML2eFuitq/pGl1XnChHWtr5Hv2XJbqNQtJ7q1w7X5CIVjURqY+JCsQHi3gncCi+i6rC+Ctj3ccqL1wR/sJ1NxkHi6HQeCNwETW0kH3eCybN1lM2dChrCtfTtiJDpvjKHcMHNPI8A4d2qvmiw0DSVfHq8="
        "itiv-foyerscreen2.itiv.kit.edu ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOE/2h4Vh/xaKrRzoqg1AraR7hCYnSlJdWzZ1JeNm4CDx1JOZU4eXpsv/Wddugbi+lBr+qPmnx2gXtRXaW3OWs4="
        "itiv-foyerscreen2.itiv.kit.edu ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwnUfpCNDTzDeNvHn7x+G3E/UXC7FUy3szeci5H6nQW"
      ];
      overrides = {
        user = "pi";
        proxyJump = "nixos-substitute";
      };
      gpgSocket = null;
    };
    "itiv-infopi1" = {
      hostname = "itiv-infopi1.itiv.kit.edu";
      hostkeys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBM3Kh1CoX8Q0cbbS5sifv1C9y9UNm69MHSAqz/PyMKObcOZ844dtLyTNoBcs9uVFHJYnRPMzMOk4AzWln6Nnt20="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDO3XOvQEr/yztNACcygXv7VUdkY1OrfJBgEJ2nGphlcHiDJDgGSJDkklkfQOQwmVkBgcEAjTOr6YjzGmWo28DrpQP71Rh3mKJddHcrQHdQX97OfN4ClJfWEpE44X8oEXpZNKJoSZ/r9pteB+eB25B+VgZMcesxJg21+KIrvuE0q4UiPnqeZkcVVawKqbLPrDcwvosew76BV3ASJehhhjMqUkhzd35asxMJxC8FNDQzjvEvN1B68aB/oajNKWATA2mLK1PwLICsukhA1IVl958gW+GZXX3Gvpfg4aJcqXzoMspPvZzfku7IQqa4anmcGHUeG0djvOh9L7F2sL48POXT"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdkYRsbztp2zo6n30cPU2VZAto864nxccfyCimk89z9"
      ];
      overrides = {
        user = "pi";
        proxyJump = "nixos-substitute";
      };
      gpgSocket = null;
    };
    "itiv-infopi2" = {
      hostname = "itiv-infopi2.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDO3XOvQEr/yztNACcygXv7VUdkY1OrfJBgEJ2nGphlcHiDJDgGSJDkklkfQOQwmVkBgcEAjTOr6YjzGmWo28DrpQP71Rh3mKJddHcrQHdQX97OfN4ClJfWEpE44X8oEXpZNKJoSZ/r9pteB+eB25B+VgZMcesxJg21+KIrvuE0q4UiPnqeZkcVVawKqbLPrDcwvosew76BV3ASJehhhjMqUkhzd35asxMJxC8FNDQzjvEvN1B68aB/oajNKWATA2mLK1PwLICsukhA1IVl958gW+GZXX3Gvpfg4aJcqXzoMspPvZzfku7IQqa4anmcGHUeG0djvOh9L7F2sL48POXT"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBM3Kh1CoX8Q0cbbS5sifv1C9y9UNm69MHSAqz/PyMKObcOZ844dtLyTNoBcs9uVFHJYnRPMzMOk4AzWln6Nnt20="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdkYRsbztp2zo6n30cPU2VZAto864nxccfyCimk89z9"
      ];
      overrides = {
        user = "pi";
        proxyJump = "nixos-substitute";
      };
      gpgSocket = null;
    };
    "itiv-339screen1" = {
      hostname = "itiv-339screen1.itiv.kit.edu";
      hostkeys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPdRz4JDu/qNH+HhQaYn4cM3CHmX8sePPb9tgBkhsKDsQV/SWGdLZl8eUP6JBryCREdSBg8rpq+uJhg+Q+TBUX8="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5Hth+DK+H23nOyMX680O4qFUoIFt1/6ZpeQErRv56HM5b3SJDutuXpr5/fQF77PiXuLtvNKvjvx76ICPpRQdQIbTN5umCxiKIHJeCXGJtvJZM7L7hVwzX1b9Io2VtXWajcyLZWvl4iBRWd51SVvgnzQOTkwfyut0wLj3BFXS2LR0CcRWWdf1do2PmYY3nAi0kH/npuhyC6tXywrKPaaIb7x7z24sKTFymTGt5mfI/2nerQB5rQS2ccnJwBZL40EhO9SIiYXNp939xQnC77QsZ+c7iHR80XNcyewV6EX/2r2y+NB19bKRWw2k55dUMdqxdxm8sUj+j9Ci113Ugn63N+UKe3L2gp4Bb8HOVZ80TnJ0ZX88/MgKZPKwnGDBMtV3+ix5XKDKzytb4MuQPLh0ot3n7zs54L7GJwzxngje+BL2yYwZK4qWahS8z9zDdH19EHjJCJZUfGVyvI3IpXgPwKXpKgRSw+xsld41ediOcm1dojJz12BGkDu//6hM0/dk="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBhSLEWPSVgPFFqtHNuu4agn4gXbuaA6yiZoJqXEHyR"
      ];
      overrides = {
        user = "pi";
        proxyJump = "nixos-substitute";
      };
      gpgSocket = null;
    };
    "itiv-339screen2" = {
      hostname = "itiv-339screen2.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5Hth+DK+H23nOyMX680O4qFUoIFt1/6ZpeQErRv56HM5b3SJDutuXpr5/fQF77PiXuLtvNKvjvx76ICPpRQdQIbTN5umCxiKIHJeCXGJtvJZM7L7hVwzX1b9Io2VtXWajcyLZWvl4iBRWd51SVvgnzQOTkwfyut0wLj3BFXS2LR0CcRWWdf1do2PmYY3nAi0kH/npuhyC6tXywrKPaaIb7x7z24sKTFymTGt5mfI/2nerQB5rQS2ccnJwBZL40EhO9SIiYXNp939xQnC77QsZ+c7iHR80XNcyewV6EX/2r2y+NB19bKRWw2k55dUMdqxdxm8sUj+j9Ci113Ugn63N+UKe3L2gp4Bb8HOVZ80TnJ0ZX88/MgKZPKwnGDBMtV3+ix5XKDKzytb4MuQPLh0ot3n7zs54L7GJwzxngje+BL2yYwZK4qWahS8z9zDdH19EHjJCJZUfGVyvI3IpXgPwKXpKgRSw+xsld41ediOcm1dojJz12BGkDu//6hM0/dk="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPdRz4JDu/qNH+HhQaYn4cM3CHmX8sePPb9tgBkhsKDsQV/SWGdLZl8eUP6JBryCREdSBg8rpq+uJhg+Q+TBUX8="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBhSLEWPSVgPFFqtHNuu4agn4gXbuaA6yiZoJqXEHyR"
      ];
      overrides = {
        user = "pi";
        proxyJump = "nixos-substitute";
      };
      gpgSocket = null;
    };
    "jumphost" = {
      hostname = "jumphost.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDji4IedxL1R+u19dIeOTBLj3GgNlSPCN3woftkaZV7fJBEcM4gHR+XWS2XCqcUE153Du/jOVlDU9GEb8zU/1FeXYi3O4LsiOShJXfi4cSRhRZaqfAkKGnOmBNhB3KCqKucVkXRyT6fvpAevn77Fqlo/HzQbVSwzf2yGm4+EDYKjfIVae77s/IiQbBFmC3jU2Jun/bHm+9T2nlZD2xNYfuX6EHLAi/wBP1tqlpTBljpjxlEj5FY3M+Ql3iZgC/BtgHKTAjz9blQUiTlmMRb3AdHuZaL3VLTdM0KliflIO4Ic9HRWV6P1zZiHfC4aRP29JZcJ5aoB/Y4cdHLKutzU9cg9KuxBL5TKZQ3OEq4X0/Iwo1uVKj1DUqAMhduAj+aTTuAoMM7GHTdyqxUMYBpW0fNzJTnk1v4JC7EN6RLzFcKe1Ctll+0k2Cakp36HUU7//pO0anEERBowodPfGyNUi5Pf8ayJcOloUqYmdVvqQA1y8+tLzsa3Zis6XTgUmdHgQE="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJYITWZ5vnWKp1QJHi8VTIaJI2SKzS3HR5cdRYt8W+zPIDpnlYtqmQFsR+xfi7G8zPPtaoTPV1RdpY/GhhB4dkY="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGiGAO4YNwJ45o3l5cM2HhtGwvGN9I2d8FFC5p8NhITq"
      ];
      gpgSocket = null;
    };
    "knowbase" = {
      hostname = "knowbase.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC73/UIzAoGZfJrfZFbvqfhbHCPPLtFrp0Orulu6J3A6XM8WLHnUSwKqGhLYAw5rMYkCUIBLbsxM2FFxMcSq9m26q13AKOGZ8FJYqohKCJTVpMziA2nvz2pyYpJm8d5H1LL2aRGG46ojQ2YQmtE5UIBk8yAGafn0PdMTEoUvtWb4hBEUEFBlRAZ4YkfqgfUK6n4mjAa7RK/ALnZ/jdwRKaPzg8lWuWMoH8/SAXeF8ZK2VTwgkMQ5N/sI8q2sB+xzILm4G3bbSVh7S0JQI6qFUD08s8H9x5db24YIkpPYgR4Rj51CcJsOU/o281xaJoT5akD0DivVD6O1xDXrZ2oEcxV"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCFJFlTmTcDzc+Sjr8uH3RAxTwMbcRjKkQ7q+IBptmpWU6otLF4yevf+3wZan6Whb6l3HLPgohGBbrvCtxp1PP0="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMCHlE9/qdJH1He3h1UeD+5n6D8S5H8PXq9fH2Ddc0p"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "lana" = {
      hostname = "lana.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCdN86FndWXY75aqrn5ZRalQCFEntmrHv8AuXytUW/4UUbswojKTwHk3OombIUR4FBsoEcffRQO6s3yB5rRsQTgb24Az21HO4g4aV5n/ycGk0lbcgLALyyjhznH8mhSYEm2g+yS3AXjhqmpkF76QZ1r+8h+3xMe8Ge3kwxX3jNqfyZkno9g5f2TlYOISKHp57QsLDWIS6PmtWpyUU2YnC+OTL19JUg7F5hgVDgSYDngIIm4gcHDpu9+ePKcK7bPmfHPKoRMzJ2AxFtv82KrlX7+tJy6gyVPS9LiyC+IQ+eQGxABylDj/TFtEgYcKoNlPJ9jOaqd+xMd2iE6UyN5XrTlKTotsgZpfkEpN+Sc5NxERhzfZNozhoueTWDrrbtQNJLg75QQ9X7cAdMeu2iXz6YzRlVLC+xZE9FzJo8oe99dOgeGfNRXleOt0GwGiqAHwS31vn+fDkQvsB83XKQoDRMOOva5ymSKL1KLrGnHhlBVMdKoqrCbX0gI3EvOFRfg+U0="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKfkMpvOxG7T4QMSoyFaGSui90mWgPkqJNGfR/YrobQ6ChuLPI9lBRM2TccANBlK50kKxVY4iCY+HD8GWZi0azw="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBcsPtPgohgkvo9gVvgJ7/Q9cbB4sTHfXWHa0hr9HF+v"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "ls3" = {
      hostname = "ls3.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDQjLSRG7E99IEftVN4mAdfzJL+msn3E3mii7Mr373Zt6SNjwEEl0afVtRVsLsWUmOm2acn1BEp6li7bMbDYfu7TsSjsgKjyGI0AjPo0Xt65HnCWbAo+teZL15iax2JdrDMPVKyRzc3RziEiQ1wGoFMtBQn8IVadOMLuEUJSsBc0q3vl/hoKDQB/yUZBgKWw43O+JttbKVGHHHMjO7Xp83ssHHg/nU16bw5A81IAHt+O7S9G6sFnzptg3cZhV/Wexr1Ja3GVw/hdSEdf1+EFW5v9NIWpWc+MLgiAZMYN6l2kiEzFvkryJuqP1gNg7zsVvOkAU7Vm4F9wb6GRx5z5aDdQRNP8ADqI7QmAvA7JbScOrUDZ8sAGldxevpqHDhkeWFctYTKVDXtqLE8fLV5YPKkD79FMuLsoFDiHRc3KwNbQcYWMhO4EQxofyIHO2WtTUtnGH11lAlKTKw4oIUSoiTjWIzS3e3uI/jrGIr57DgcScEhWQtRK3DcmxelbT2XIbM="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOrs/HTyqaUSOYaEHMZMvnAk3pS4lRQWE94bN/wR4u9lSBz0XUYzesRs442vRkHYo6nO9b0TL3+mDRoR/oI959k="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILxnkcngzs4EWMsGoNzZakwHkNQRC/g3LlL0/trKjVrm"
      ];
      overrides = {
        user = "license";
      };
      gpgSocket = null;
    };
    "lsl" = {
      hostname = "lsl.itiv.kit.edu";
      hostkeys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPTBuxvqQXxxu/FxCSO2X4ZRqW0gZhOMuPfeO9aY9RO0UA/UJq0PwcXl39Two4/Ja0+miFJYnJg6YNJu6L8atmc="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC24HSm555QTDHuzv68jKQFivdA4BgTlM/cnJex9MFz5G7bqCGZDy7VQxrAHA/SsLVVN80uB18w3V3Gqkr8S6qtBUTm2N+43u12CzLyeESH4VWb6LnWvoZa3SMaaYmpn/ZWgOgzyIfBWZdy3wlAh9hSGeZuCR4PHWIW/S+o4rLXTeyM+rfstRj9N2mPRRqrhqJBf1y+pfKZMhCC0mNt4Z7oNe0vLOj+wlMggiVIfVnhdtpMAhfMGc4sAML8LJqLgWOZ6aI6yyt9Ur/52Zd29B6M3qQCccZjq1alflW9Hbl8GENK0jermPtyCFLgIaEkx1Ar3dooLs1jeFOvIcknzADicRMHgtb3kzCVYrQ5SrAsDv/7f5H0wI/Wo24cy50JnLZBIe8KkmK/DPNPZr/qDhFyUa286EsIIs9VAfuW8MGqtpA6t9YEWQNNvSf7HBxnbCi/RRmwvefgvIfITg1VlCsJsddSbezf+/6POyjirsE/2q3sINl1gHifu1feAT8UFsc="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKY76h3X7hdfZWslyOSlXF3lTjK0rfh8ifbuLFRPLFr"
      ];
      overrides = {
        user = "license";
      };
      gpgSocket = null;
    };
    "lsl-root" = {
      hostname = "lsl.itiv.kit.edu";
      hostkeys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPTBuxvqQXxxu/FxCSO2X4ZRqW0gZhOMuPfeO9aY9RO0UA/UJq0PwcXl39Two4/Ja0+miFJYnJg6YNJu6L8atmc="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC24HSm555QTDHuzv68jKQFivdA4BgTlM/cnJex9MFz5G7bqCGZDy7VQxrAHA/SsLVVN80uB18w3V3Gqkr8S6qtBUTm2N+43u12CzLyeESH4VWb6LnWvoZa3SMaaYmpn/ZWgOgzyIfBWZdy3wlAh9hSGeZuCR4PHWIW/S+o4rLXTeyM+rfstRj9N2mPRRqrhqJBf1y+pfKZMhCC0mNt4Z7oNe0vLOj+wlMggiVIfVnhdtpMAhfMGc4sAML8LJqLgWOZ6aI6yyt9Ur/52Zd29B6M3qQCccZjq1alflW9Hbl8GENK0jermPtyCFLgIaEkx1Ar3dooLs1jeFOvIcknzADicRMHgtb3kzCVYrQ5SrAsDv/7f5H0wI/Wo24cy50JnLZBIe8KkmK/DPNPZr/qDhFyUa286EsIIs9VAfuW8MGqtpA6t9YEWQNNvSf7HBxnbCi/RRmwvefgvIfITg1VlCsJsddSbezf+/6POyjirsE/2q3sINl1gHifu1feAT8UFsc="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKY76h3X7hdfZWslyOSlXF3lTjK0rfh8ifbuLFRPLFr"
      ];
      overrides = {
        user = "root";
      };
      gpgSocket = null;
    };
    "metistestbench1" = {
      hostname = "metistestbench1.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYmDM8o8VnI/CkTOchB2tHzxC3Oc2XdxqRiEZ2nXsN+2hVXx4yKT9eSWCqPGd/4Ch/jFl2j6gQvOzxQZkR0F+oVLIiFJkpAYOWZLZgxUVc4A523LvM6hKvdghUbpQ5nkWG+Qp3zEF4/Dw0ExQ8t+OsbMPhXgjBWfy6AlUocy+mTcvwH4/CQiO9fPQ53hxC4xS74Lc5oP+jqoWcLMUGz1pk0A2Zgo3nDoFqEWNpX8hAn/6KiCDTYcYcROG3ZuHh68PSX8hdkfxjfs4umC92OlmH2NJALtOT1w679igEBGIE9NxsyYyd2lPUmVWhqFxUNxHVpKoSlI8klO+CycoX3tJ+Isksy4Uk6j0+4Lq1c+Fx6353GDlAOYqoEZAm3kqcVX1BfaxaMWm86C78/XrnG055CHtzuZSLsS7oJ9yzYToGKk7NCWoUdQLQOTk/dlwOPiGX5pTCr3B6pJykx5IaNkVxiB2LRk+SnUfHkCnTjuS0eC2z2Fe1kKLIAx55mktxYjs="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEGfwH2Jod+CvmXP9eTeT4P1bTb4g1cuhNFKEdBDAo89vIKQEb6HezDrhYDV2cslY/xIOnH9XXxZDNRCQf7gZH8="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHnLjmoxZlJYJznJh9BN9iEUlE9qMe4+UMRYMJJaIBFp"
      ];
      overrides = {
        user = "root";
      };
      gpgSocket = null;
    };
    "metiscluster1" = {
      hostname = "metiscluster1.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7le9MDwdMCvmVWu3mT5lunyb6mlpi9r5XUvKHXiHBgjIwFkkT+AjqSCCKIkxE4DJzXgWOhoiU35xVAnARS0MAkwc1Br7JXVVcT7TPS1qGMo9H8QKRMpZV7xoOI50tm4Zwrn4P7KXaIyjxoP1kN6BCQIhVYD4KmK7bmqwWfn/KVcd4CTBNp9fFrEdfsK0wf+VN8tc4K5mI3qb2InU8yrRy3USEbYeJly1N4623VaRGDqUPvW5GefyhH+G3CLv8ix/jtyOvG1jc1VsAMGP66+TYBRFD56KZ8pnTdBbwqpfKSP9P1ZdhYdeUF5Xw2EW37q+hmRpiyptkOpPi+p0I3+HKM9yMdxM29qlcouHduhKBThkyKH/z0g6xj6TD1F92VQu1RZIQFK9rcfrOxeCkV39m/uHAON3bxIre3/hSB736K3rFb5a0nItDWjv6AznVR4R6wBxyFGcGiFBFSwgYyqREuiiGG1Od+EpTDSay2GO4TtZ7iVOctFtpuj8RgLeNPuk="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNVxcs6dUs1qJmwuSAsP+6F3NHx5yf/GxKyzBJ5Coi+cG0RKBNFrTO8ZQ6U4r32MzLw+BBB22PERdaaZfcyN+xE="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHnbpquW5ZzcUBaDepDwkXL0XkZ9fypgIzWMiH25r6tT"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "metiscluster2" = {
      hostname = "metiscluster2.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDkvyYyG33pVPLAPa9I3OcEmLmmpxOP5B6h1IWCVyg/tPHm8BUoub4b/eapZNrFchuubqtpqtqqpI71ikz7PkrbRCpNOzlHFDGX4IXft2IpXjJzB9QLiMJwYN4gSOCAV2qXlHJ0/9+FC/L8sxj1fx93JVa0aayl7XWH8eXCVHs1vgTTd/4j9e/CNR4tqZ2YNEYWhG/r94q30beED3y66fR4UoooLW1Nyrei61KN3oLMy0nGFNllcWF4nF+7cn9Dp2Ch/CW+QTgJaFUmb7+0/yF+bxK5a5nTEAngi8w2CSmTZIKuNzHGM0hsWxMR7BjKxjytd3otdipwFC36cz69+Q+xdO8Hy6rEdqVKaSZ7i8x3wQO6IAludMSsCZc6INveqHt4EVd0MvcwJALo7BUilgOQAl8vqP4zlaFsSolCrxE+XMSqUHX8RkmZgIqa6yu4VlJbcZLxwIRUnO6dqAuTAiNMFk0vjib3jqduClw57LU1kp/p3PXpKXyImQMUgQxhvg0="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGeg4O6jwpnv2J7AEEOEXuYEctlpiC7qAshvoRSIm3OjZ819O3BNq4eRcphsvt2NFqsbDnTku5kmkH6jnxOt0EQ="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICcFDv4i9ChtiG/qsDSbQflSUiqwx03JmMEejOCWX1J7"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "metiscluster3" = {
      hostname = "metiscluster3.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUrvKwLB5x7yQVg8VTm6WI1CIIwmw1sxdmzOznV1gnyEYNEa6E6h224DdU3qzZxsJHx2pb2PCs2eH++ckcZ/OYej1TmcXbiLfr95f8SeoVxtSZvBmD80xNjgnupeWYsDtPdZcMnpw6CscmWNeX/vDwilKvVcCEhofbjFwNU8Y5Wg1IUE75xGwC3YpMXQwtcOzRSz9L0P8CfD32/Cft3r3HpF8c4QaVrjhybkL7IyB5V3xQRQtW5DwjpE15P3dcCWlGOUqp+kAFaaKVHJy0MqQnS628r3bPsedzFf+xfs5af2SrYc7CoIQN3rYsMKccZsiVoRuZ7HixvSYX8Id1+/GLfxoUf9JL0Yptaq12+uGWa1oju7b7gKFEkYsd8bu3PgWbA75XPZmAt7lDXCRmePnhPPPMJVX8eWE+aknrHZG4m46Ve3FZzMniyatQ++omJ1I15oddPUGx3qTvSmybw2mAa37ODxRFsCdls6tRgYpKyq2xMUoJ9S1UucWSfT+IUY0="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIXMOKXlcFpDFo+1+nEUocYZfIvEqrmwGOnZxo2y6yzQqZUmro75JZa/CjzyqEQYuDb9TOQ1vZVnHtpUKUdqpIg="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiscGp216J9nFzPerEDHQKsUfUCM9ndLiLPObuzvLRJ"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "metiscluster4" = {
      hostname = "metiscluster4.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxRePwtYIqmJvqwW0LYrLVBflkw337UKymCy4JEvCQXGudvZcM/t6WInWCWrAnFNdb2guBwqM/FCMnqCp9yoZkhOJW5pA3ZZXnmyD25sCqK91dysS65Np1PHXOzkFZNw9hF8twHQW7+opCcZwo1GGModTPlGnComGInqkqbmaedxovLLbbSkQiLnbA/vt1kYsp8zW1eH2kkvL9ZgqJbbJMO8gaigXDlad2n763gmreNH7oXeVUZytMHFgBs4UjJRPkZmuodprtMpTPBUa5nlGNWDkw69LD45NWcEyJl8HmiqbVws4lfsSJXhWRewT3gDILUyEt8cNjc+bEHOBx7Tv7EGrYDAB+VIPFKYge/TlCXY9bd977Yws+HMZV2MwEJewwlp1KnX0vVdFJVPL9rHutfFLEXG8FWi99ycj8KrO6SgTudN1barsX4Y9QUnuVa/d+fUNn/lsztyRcqrNtS39nkDpvwk05lDrWtVSx0AMo7yc9SpqCs1H+ESkpcId1mvk="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBItZTR073dvwzzcj2oXAQDY9ntGM45o2aKKZhB6RcSoJVI1+V3HKu/mD41qP4DpV67yKdc4SAWrbVVPUEtoDlvc="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbhgz4gVtx1Yy0eqOhYxn4/5kc2q7emnyHEblLnY2F+"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "metiscluster5" = {
      hostname = "metiscluster5.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrWpypjZSKJmCNfusCNy85+rktSy7yeYb/KQ0cjeAmPdJ3otf/nUAinB6NJpH90Mmj2vy8GtXD2NZKnuNoNku7nAOQUr5C9FGQpemwnZpBKn5tTmlbSthvegc+kvJs+NsH8P4tqq6ddpuqaKTtOe90fo1b/Fuh/3wTLA3/Y4o883aPteXzFi/ctacsVuW5IZ6SAlJyPFX2gOQSy5qa+3VTezSTbEccm+kEVHVSk+xZRHVIuzucqMcPCujt1YpzpY4xTLNUf5aHHEKVbj04tanFS5Qa9ZoAz859PXcBxUKGRtX6Ha5N8mWMJaFL2bP+nqMK2ILKFK4XPq+85yuvvHmoOYtvuwXwjYpIZoRiiZyfK7AjArH5wnjVdcJZg/lYiv0DK6flvH0mklhON+edY5gMDz5mf3A6adKETU03MmkEetTk1QJ9uvp1xlEGM56cUQEbHo4HildiR8uI5nKYXco/DbXi9HgvomGN4wrf+h1e7/26WFC2cwTeWfIHyowXCgc="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJI6I1+DZ5fh9Y3SOqki9q1Dkp+BxRkgosmtrPGeOYDVWu1qeTxKXNITEqC40UIMJNa70KPKxlsGBxmnISN9Sdg="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJeFb0Id/HuUupJsH4yYD03fcE3ckisAGQtpg5m1Lew2"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "metiscluster6" = {
      hostname = "metiscluster6.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGJUCJbjBkipJO0HgoHmQROIcR5s4x6gTm+S1eLafyjM5oF9lLgDB7mbonAzMByQ/EGHxr+lmbRgmsZFVpqY3f5Hwmnx8VC7+32R3e+HDBsVJDJNOcvKW4FXk1U5i3GyyLvDitzc4hsRYcOh3VCocZzluXA3UI//im8s0PyuPUn+jqwhG2SQwqHAvScftOZYhuUpDQRk9mMTvOHc/Gr1YEUjbYfWQi48JHZfx6V5gCrkkRsjOVQjRxXZug2YSPT6towSvOM0/oWswS15+gii4cyFOyNYimFBNTD8NJpsBGDk60WcsXQfnPPMOQkN9kiKn4GSigyRyIT2KboQyrJVK7Zibwv7+Fxfn8TuRlNFldPPpoDw0DBFdGZfGCCRCCw2uVx3hWbBx0OcPtZrVuXrlt+UaE45eefJSKdF2cZqjZ61KYnNiHq6YbBZERN/ZMtth77Hdin79gCuxJ+OwdZ1p43VlwYODIlYcg+bZdv9VDPFqnatVz4hg5LUGpDWm2Eb0="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMUYvbuRSq2kB17yV9GXye8xZAmi9rNYaudSdSFMypzxWF4sHoZHbNb1RQDNwKgk+NO2nQA3p5oz8Cs3eC8E0QE="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILoSr9ok+qxhd9rcsLfs+RKwAqqxznzW6NjtlGyvdJRd"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "metiscluster7" = {
      hostname = "metiscluster7.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCgGAf/Lkelm8dCqlTu18RGKH9hSosfMKWpTTnnlZ17Sh76nYY1y9CEL6Q5mvvw0tVlxMA8kUPPDzTaXHsYnDmZMOhE0OD2On+Mvg/9SgMvdibbTZpkuqtzLAiqkHjRdrC4J+OSCUgEcymlx7X4kBJjCWWmh4qQRt5EoXeQzdAYaCfo6qMu+eO9KhczSInmhj/eKSq1A/z1dPHT7gWtkrV3Aqz60LlCbRRQkEtBk3y9GiWixI8hz+lKQ16SqSlD2Qi4b/72ZK17NcS6/B03v6eXrdSr7FMLfeVUoZUVpihBpO6jurlfpJlWwTFmRZr1YJn9zVJ9NaDvKCti3R9BWE8fqI68GvQYRsUXTyhF7kfYUquF5f7UbXrwFDgULVPsqMcQ0GG1IqGNVV0JJ9haBhyydKstA3dbiVk+SaUMZCMx4KqEc2BJMbeW0gDmCO+plVIr9h2z+uMnUU6qY6pjgyHbcyuQao9pUV3v2tFVNt+YOw4BF1J1aLat8J1ElDHHGI0="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCbaLfYPIYz41oVJrOlm0ypYHhAeN+ffReHYp1Py+zCgt+nSKUQz88OHvK6/nZBJqYZtl1O6dg2ZIxNqsjZ1oKc="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHq3rygNMHwxIXdNG6cdtdkHhODG23G+RkDQPWyh09tC"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "metiscluster8" = {
      hostname = "metiscluster8.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNYJb1aLoCUro+W9b3aiprNgp5ir2ltaJyOWKKOai4FHeG+jF2Zh4tTn1AhRfZMn46jVC1CDZ+r4V6xeEMIXG/UTvwTtLtUdF79MMGCmBPsB2cPFsZr1ZM8PhaBxPE+MfPZ1TR4YXO/3B68gQJ3FwmAYor8Lrid6pLtci2RiSmpnCdtLwsL/+EKuWxFovFgYzcyv9q7zX2Z+L7QChyZ4p+QmHuDgkP8HmKIE79Mk1w+DWEdotzmio134hxvlDwVRmEJZiZacnky1AB47AD5Ni23jC6yZz++yK/uz1VszG6jUQxMWM9NUedybjgldOIFvqDNCO36OGj6slT2qzME0ZmGakp9eQf2YBilWZRxm5yOKH4fZja0+47022j7dPJmPFUtcTlo+vX804eubpqYYQvQxEhcxlPnoaIp1vThcUda16307tB0HQrCy4U0/z8+/u6VdmjcTjn78Xo5xd4g6cieHfDvC7Mj+0kBhcBKGqt6ukq5xOa82qikpriPQQ+ASM="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEyI47xvHUHpXY1pbf2z1otcrC+iO+SDZrI256sNa/tIGmskc5q7VXUkgVg9Fwvz6kjXndSQYI+ObHugq/UkeWA="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGFAnqeL5sCs9jJIa05KMMQCneWBJbWX966JnCkPTjuW"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "metiscluster9" = {
      hostname = "metiscluster9.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCOmueRBHSk5/DRpLhCZjBi7/TB2X22ZoLn663eGwOAxeVEeP5YfVePHSDA+KcRfvH+rPPWyNP8kAaCFoWqKT8SKl9gtDy8AKp0LQhBrxnMAA7/f+BrCxuFm9l/afCjVGr4Ufx4V13zYLDjdHsZcWSV0tn5lcDW+s8xTmVOI4R2jHS2NX2HvmP10EspXUezhyrBLcFw0MjTpL/xQ5CIH42gMB+jGoPbjiHfHULN1Un/3cedOWc5jun3wkklZzi445dqdkgft4ki3e1kDV6CHBJcwsrnUrq+0HSmuU9GZQ/v1jyNBIZZNlLjVXfKjlpdtLCIrr96u4gXJGPoCH76pC+x4P/VvacId6pfDbYJU1HeRlvYvNTphyHX3hlWvnvy+6GcYf5wCxDuX/TC+gZlQvbJIWqJjjohGGyUL3IWDwNZZUdU9o67u/D2i0tC80EXgV6mta+wuIQi3QS8HNwCMR6LvRckMctMHK8xgIpkCGFs1WaMZE1pV8tgWq0G2sSr/+8="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDJ+RQo72jncX/2MUzgtvB/f7Ys9hk8roWFvkBhTuQOpmIaFbfOVxrgPjAtZ/kiXSxUDTLPcFSqmJ98xQujw2d0="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIIgUw4W0JxbFzblr4/BdlmZ9n6YQwFiT2zArg4UH2WZ"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "metiscluster10" = {
      hostname = "metiscluster10.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiPkyG0/x7FPxoh1WWAy1q6p49mVlEJYQBciJJ/0AACxWmyDiCvzMz/RAz+TmVvTy30Zybrwg1d+BUdF9kyvq+owMpC466rZgD1rCc7EKXYekcY7wG3l1zihVCuC2KUtfKIf/btyDQExO3rXIRGzV11zrUpdM8k2sm3XhMWyjrDWz7FalI70Alc23ePPvhNUNqPFNNpk760mrBQ5sPvX3UM7Pcc/6pGuZxT0/yKsAQuIFg01Fa9xXxQHwO7YVqMwSyKc9X8x1Y9qgNv3xIHMag65dKkpvduIElIIUYTePUsMYFSwM9baSXNWgv10ikyhJ4eVowFFZlznAQIHd7punGN1LM4I5W4tNaewPhdGZ1ZewmWQzkfAYPJ3wfNhkaCxaZ096LhBuoE2vADIhg4VJ1lJbi2dx1epw7wGChLTYCOrChn+NZBYvAP6U0PGfazmZy+bZe8okWxIi9FHbeZL5RQrp9j34HReZeSrKx70ngjS6IdwH1Ik2tuu21K/qFtf8="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDy6bL2PqRt488y0myEUI4dBtY9HGoOYFKbXZlmK+WfyBUG++rga4+Xviyj/4mZJQARXKKH1G2xtNqMX1d5K7zA="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO77FitRtj29mFzWYm9/qE6XsDvf3g8/HYm1sgZkPbF8"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "metiscluster11" = {
      hostname = "metiscluster11.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpJbNnpqYTRlixkM4q/xQOd8zPCPNWf32B2rX+ULcv69+J3gzIVbS6bNOgamPCWabb5g8XynRhBAj01GCYV5qRVriZ6ucC2CR3BHfYqKvSTmWPWD6ctn4Zr7Nwb8+X49G306+zzZFlf0aWehrAs1VuAAXu6Aq6NwNsguISeJ/CTFEfYvyW1ozSgP4v/QA38TJgp+lSFRDdr8zNNUzQO32XDMwuQBHOl5swkIljgbsMltOnNXEnRcvEWOvWp8UlpdphAVwzCQEo5dUz3hxUV4WVpXb4FwW+dkwkBf6TXNOAfkEIj14JDMXbYH3sCjqAEKwVpw0KHC3t6i4eAUV1/8RX7BmZfozbqO+qdzsVgXJymjJxtYEYy0atIfcRQjeUBV1+rzPg23rGiteEOtjEstoQWAByNMI+lsDYFdDvRP693LuxWui3DjniPA/Pk283H9YWp0SWOnaSCndz44ywddw0MREB0qbVu5/JCkHuVl+sADvhBVphoUnyXULNWto+vYE="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOScKnkWEUmIvCPS5KsyRctPCYDwg88Gkwp7K/zd/FZTP+zDK1jriiWm+62EOVMIcLFTZ8TQFZCXSC05WlL76ZM="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBKiWsyQB+BqeW8qUufznM0oUmeggsxLVOpBhMONH0Vq"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "metiscluster12" = {
      hostname = "metiscluster12.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7Eo33UzwkcI77Q5603MXA7QU9jw37WaHNadblTSUjTd3igXwEqGTFQZ8rIpiwiEkNDQ3MunfDQx+DcXyBp96JpL3yMwj/lzv+SJg0lGVrdW7sRQfRXmm+LuJj7xiyQnmBLtyYpj2PZXNxRTbVtN6K6cyWyQekFnE8W9bm4tWmyLZwK2ZEjrmDArHszLsGj8b2wXavmHo3+UZuzUk4i+FvcTT8ALgM3g3DAwyjsNIKCBJRa6eWo6zw5TUCr5lVm0yym851mKmo/TF2NGALNMfElbFCvCk17FPSoIrjTT0LqxLMiMFItl92FcbpynM0CAmhc4uoPEKNyZVSZw25Cx13pes1G50fFZDUZ5cVA3h4lrAO6bvDM+INFzB+6lYSM8MQIxjk4kTPGaBZh4XzmcRFzAsfCFvKaCagRn4DLqdUPY8A6L2cZ5U2z4gqordLUv1wNw3nYV5SJmei6UTqJRJcUv1gd0Q+cvjDBwQFR5hwtc9HoNLl6bLvnmdW6eC2gyM="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEB6prQ0YueQ2vottuEaTI12ilgpnjp+4jVjvt+/MAGHQfIGLaR/3mrF9oEDjO/t2Isjd+S6Q+hlgZWzkl9r3ng="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOTL4OKgaKp9LNFyIRnUQu+8Ol8simD82+Lhex+j8fX"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "mgmt" = {
      hostname = "mgmt.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHoxumc2BG1+GMKuJDhWkgUB7dDkEFaUIHZFsnOSwc7TN5s7Ee1sK4ZW1DzidGxguxcYVKDv/CcI4P+AnsmABMew9i/mPAa4k5RIFHmN6WE6/5Y8KcKrNn2UlbT4AdVWrG5qOeiDp9cBVC4V8MEDeg2coxc/nUHHdo1FQeXc9P3tg2W7c47A2IQLrvL5hBCJbiu2yzMD+0GJooH5L61btNCSKdNijOC51pPohQMfmXzmP7kOZaWqXuV2QyVp3A70wwWWCge6Q74g/2Ox9gCQJEqOFQnZWgVhSW6rMo3X/zK36B7i/hTMpTbF33wxTuVGqBNLS8EwMVetkn+IABfymJ20bmZfCVEG9xfDvef9bxtC2OjZqGRDuOC2+4B/SNxC6p82xxU/yl1Kq8JIm/K//FvYwsbdah0rhoiwd+SnxakVsJZmfT0XNTz2k8v7mQEGaK2D3IQfjFUMKoYpLhS6OMv+iMAoOuZpOycZ457oY4wHtKg6QyCMES29efaHB7uls="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCxHWSZZw4Nxojl8RC9EDy4iA1XkvsmP6IPvwjYiPoTJY82aHF4Ae79E2KXmFzkaHyYabCjpHxnwKi8gTx5Xgdw="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGkethrszB9ygBHEHfVFJm7GAVAWL9h9Ed0hvhFjD/Q0"
      ];
      gpgSocket = null;
    };
    "monitoring" = {
      hostname = "monitoring.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMC0LjuNSq+2GtgB4joPqHpDH+i1rFMXemSGsT5aHgfNMC2zbCB1Fro2SgcVlGuwqz31+9jErNG8mkHq0g61lOBJSt/OzHQxuqwKtqK+n7vRN1EIQOHSnxZmRrPpvx5oqJzjKQQ9mxnb+k/g02rx/YfhDIELNXsuwXFCbXvjwXV38b7ylQ8N/6GKSlj1UZm6QMA18718aT/xfEEgqj9IdBPUwguFHKP+0Z+fB3zerI3Yftw9VDvLliyjDmAvsMe24317NYp4z6mvcBRRYFt9yxG5SORhiPXdZghdkRW8QS52oBI3FiLThedVO8L67TR1pFDJTQU30zRy1ojmZlF4Yp"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMHiBj79betDIvdH3ocZmVP13ccrb6viR83+a1DZF2VHmTF++bMNnMqrjkRdAb7ViViNO+FW9/p99wFPaHO5UeU="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBtmfvz9UUxr+4pNA125tznLiYwLDzRXclfTbwZhJWDv"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "nixos-substitute" = {
      hostname = "nixos-substitute.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOksupsvA7m6OJ7z0gK1Bit3tlE4drw9z0XtXOt1IaHH8zuW+Hy6RSTHLv1RA97Z8VCNF2m5erNd03PQ0eLgIF9DVrfaI4G1UzQB54dhL9GISG4VBDlPG1L+pRBckpgWCXHo94nWpdgYQA1D4LtwwSkAsjNuSlxm6O46zlS/XjiPArms0KoVMOGUUnaBBWKF3kF4F0R4E3859Kyo30Yohulii8T3Bo/gGpZyffV9iIHWZtv6Pi9+2JOh3TOsyJ5tf3GYX49yB/J4RmDqDov0yGxgiJiNnH5LYacWhfNfeHTOmNf2sGzgQanP1tGkyiMbfZefHbB/GOpqdtBcfKq9KBborQguGNQnzVlp4HnKCRu2v6ezATOLEG5SRHjHtVYklI7FFL2f+jzHnY67z4ZlYXtdwnuue2yH43UhUIOOOnXnl4l6EI46mmstid/DAAQ47PaZMb/nnGtks90EKwTeVbv9YNTAvFzK11ks1uXRUJKzHvhDw58Sc4ya7tzYUTMJChGm6RC0Dq1VIzfWpD4X+U2fvnghhZX8c0aShUOalkgONlf46S7lm1RwbMKsQcVAHmpMvyu5wfLcfkdKWcBvvJJ+HLdOpZl3De71Xxt1/tL8mShpT11Vn68ZltxU7YX30ZbKbPAPclcemxMc7KLgZzTuSwgDfUVcnSu0d/Hw/uwQ=="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIWKUNueuWanuJjxsOsbAc3JpzGTR3FuVDXSkEuymQFt"
      ];
    };
    "opsi-c" = {
      hostname = "opsi-c.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCnFguixHWcVKRkbej5j0JR6lMk+e81nDeD1A9Xb0P3mfah2eSEdvd3BoSObgbzcvX+2p4sRJnKE2LFMX611Xf4/p6l5qPeugki4lkl0Gd9canKV7XECCAmBSH+byaF9GlxtQeJueMbhGJPeSKpANnHmYhbdr0zfqJUsRxXbxAdKLlyrj9lcL71iUixMwBkqOo+ttGA3x0cEEKyFcxonQM8VJgho1WNjaI1wOtYC/am1wpybH01m3FKxHMHs9IvVtcHtpxd8xzh8Io4Z/cGSOwQOF9Wulpd3v6N+dIPSM2RvMoPeJFKjCbKuKG7ASo8rc9pHqaOaa6BAyMcLarmMCfj"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBB0fmNgD8jczQAcUhf1NVTKSZnkW8aoqe5uXj1Rpi/ZuSDPjc0jNcNF1yq4NWK4qhr+D4+Tq2SNBl3Ty55IYJ4M="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIO6ArbChkvDPvf3A0CQKdntAlcL6SZKf5UK+29vWn2T"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "pool-fedora" = {
      hostname = "pool-fedora.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDclQ80EnX/Jx1DlbRSG7zxFZ1sAlMfqKbsroFCqXMuJvwRfJ7xycYlWjfkglbhG+tzKpIBcHRGDlSrvQoKL0BfNkVxBND7YzHIza4yVMrm00Rs6JMKNrGzSOZfvTFrwp6uOmTgyDpe34X+z07Is/kb7mG7z0DWG7FVkhI0eCFDp8u/x0hHJBs8RUdZd6EmOck0t03K6mRNt70Z3Dxyn4g33EOYOFLrH7UeHgqI44wEkWZ+Wp27m+bk43OTQf4T49X0UTVVloFTYMxR7xE7//U8PtuJrGFKeaK4FcQAcSLz4PA+dfBWh2kmF0gTgggtpIHU1lpKQQniIU2Uc6TvQBfco3QtJ3gSFO9m8gekdlkHZiRb19UjqzlgBx3OHV62dRFujzz0qhrAlPh7DxsDuJPCCmFvVjffpumgxuB1pm4na+9UbcFJwKK0eXJWX2MJPbTXYyAFE7mPJ54QOeqQmxMrtGNab1KkoPt33nPdiDIfyKgvUHFl0NYLwNNCHjmgTT8="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBA1FC91DOfQOBG9s1Cu/5zgJ0NgG4+8r6TudpLsWqiZyIIKmhNy8x9LlVA+TU6QxoV4Df63TX2OS4oiqqEYz3vQ="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEUSCmmXnHNb+zsyrxI737tXW45WSjlKPpM7uGJRNt2"
      ];
      gpgSocket = null;
    };
    "pool-fedora-root" = {
      hostname = "pool-fedora.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDclQ80EnX/Jx1DlbRSG7zxFZ1sAlMfqKbsroFCqXMuJvwRfJ7xycYlWjfkglbhG+tzKpIBcHRGDlSrvQoKL0BfNkVxBND7YzHIza4yVMrm00Rs6JMKNrGzSOZfvTFrwp6uOmTgyDpe34X+z07Is/kb7mG7z0DWG7FVkhI0eCFDp8u/x0hHJBs8RUdZd6EmOck0t03K6mRNt70Z3Dxyn4g33EOYOFLrH7UeHgqI44wEkWZ+Wp27m+bk43OTQf4T49X0UTVVloFTYMxR7xE7//U8PtuJrGFKeaK4FcQAcSLz4PA+dfBWh2kmF0gTgggtpIHU1lpKQQniIU2Uc6TvQBfco3QtJ3gSFO9m8gekdlkHZiRb19UjqzlgBx3OHV62dRFujzz0qhrAlPh7DxsDuJPCCmFvVjffpumgxuB1pm4na+9UbcFJwKK0eXJWX2MJPbTXYyAFE7mPJ54QOeqQmxMrtGNab1KkoPt33nPdiDIfyKgvUHFl0NYLwNNCHjmgTT8="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBA1FC91DOfQOBG9s1Cu/5zgJ0NgG4+8r6TudpLsWqiZyIIKmhNy8x9LlVA+TU6QxoV4Df63TX2OS4oiqqEYz3vQ="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEUSCmmXnHNb+zsyrxI737tXW45WSjlKPpM7uGJRNt2"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "pool-linux" = {
      hostname = "pool-linux.itiv.kit.edu";
      hostkeys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDAaJcJETuSeoOizQGZZ+w7l9JG5Gqty5U1eZkLCjtZg8dOw7qwcut/sU1eMnTJ/7oXSJ87cu/XcGquVVRXLYxM="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChpV2kOL93xL+uOtbgKd+vjLnRAS2UJfYTDbgtV5vw5utYcyA2grfnW+4qk872XagveB/2LaQ+kgGPZ7zrpCqRegK7JM60bm+b3wHB3ig57moEX1wGJGCbpug3D8/c1POVDe0/Rf6VM3OLkCcV9MhF9aA/VX9YV5ocm0vM75O+hGN1FHi26QtWKWmoMwROq9sKqgUQb9bDReHtjFa29yGY6fo+EsoBjYZXfICeRRIxOldlJsM+rh9ZbSVf1MS96VJ9eT7gy7BgZWyh4EXRbhC7HRLv/Al64GQBvdvBBUbA71EBEspzsvuF6XAkbpWm1yPzvC2VTp4krv6rXPn7CgCE04NhaE+DT/OysfPDTXtawcn4aVdxrajIyQuL6spd8ZFw4072/EsndRcbGnykE+sLblG4oPV90XbflKYWyBSMML8mT9Q5dWMrXxpMZ785GnE9KdeuIIXCNdHyQBkUABPSHuJliQByPrbe+vuvyFuo0IMEL08LUYTbsaZsDRep9gU="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAZCGDw3vfDbcjp2xsCGYlU3TnSkSbLM+VkgKGg2mXHW"
      ];
      gpgSocket = null;
    };
    "pool-rocky10" = {
      hostname = "pool-rocky10.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDJ6vgeMPQrXYyQJYnxCKD6qgVgb0n4kcZtnKo1LBXAl2/KXIFzmboTcvUPQR3ZjEgsZN6QKzHdnfewhFT3M/cK5Pbpp/mrylSRIcPjvTMtXZL/80GAUPktn00aK53s+WLhJceyiAT+qNdC3W3IyA95oOY3H9qjIdfFuYROaAXE7fAm7waNWJhindQms+y2DleTne+6AMCZHSGtYBXPUiLWq2mYTK9v+pruo8Ry6XAFeGurAB9PGazNqdxJn4Fr9KVw7rQvl2itwfp8f10SUhco2sMLLM6BakutCsMgSV8snun4/bq3Vwl498wmcHfWiAjSL66SSliN5sMFelaW85lPhcWgvRdrMNCwWprRF7S4Pr7hf2INWxDlV3IhdHLc0qlBqmtVl2BJOHvx5T/BHCG4z00B0OZD73HuOV77d2P3dq2Pvr8ZUOMHCa2EY7rP0H8lk+wtH2FYslKXeAslUm1yM2TRoi/87JXC3owwBSmseqBu5+yxuJs652YXyo/pM0="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBG7ydnvXw/+rkgId1LH+SDgl/dYQxQNQ2VV+jESz2mRakPRjUoR0BfnpKnoKu3RLgGNYw93bIpGQLvjt2ZC59D0="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINXzXJVkgpUyCD/7OQTv9OqiRRs80vbkigXpayQWtGwI"
      ];
      gpgSocket = null;
    };
    "pool-ubuntu2404" = {
      hostname = "pool-ubuntu2404.itiv.kit.edu";
      hostkeys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEOKjG4HKacrK+zhW1int/MamMrQCKDMKtRAFTi2FQY9DGkDtL+8paz8aTgLe37hicsCP0wSi4N1HLWX8lIIVKA="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCsHmme1JZZnKvCxvOV8HiWVVl135xzJhWnsLv3IojNeOD9x6tta2VdDGKzZvsgH0Bt1ndYusaR+8plariyZ9j1+XwNjjUk4FWgcPJEXxUuqSjWrTncSTwh6OOASj8gyska3seuxFD0VL2ZPyNnC/MDozwWqqC7TfseH4YCCxUIt7albl/jHFYRHuPEKe6FcUNUQ2Crf+xFeWZmLED7DY/bL0x6IdqLIIX93llvWsuZpywrFcddQrgwnIbJgbwZaf9DkOh95zVLMArKQQqX8XjoI51rZbO8dK8CTAN54NJzJps9EkcilAv3nb1AenVjvVFJ5/k2K7fDnVCDstFjly4FTvef0vXLKwRm4c2m3dY11qQGTvU74p5SkvdlrpwCmCmtyx/mKlN5vFdCa7xG6w9rh8d7bPiMLuTrRUa+eJx5+cuobfJFz0JTI+iRjkFW4yT1CsZbCzcIIGoRB2sTSRXxh4GolK0mDT6czvhRrj9S88HX+IjP8YnxnXEuovh56dk="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMB5b9Y+pgrkCJb33P7FzA2yZpyjvT9zN1EU+JQA9IQV"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "runner" = {
      hostname = "runner.itiv.kit.edu";
      hostkeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuyj8iDmsOZAq0Eutnf3i9tuU4kqofxuqJ8fowqfSzN"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8Dg8sVenIzvIw2n4nEp5sCTcQUewenz59XTqVjRWHC0kzaVioJPYSXFE8HELSejdxiutcKg+Jm9u5AtfDyHgMGivkF/QzP10aji7IPeKU4YRZ/FXnih5qQu8Tbl41zVqksbpG2R3fJlHAYByxXLCnWPnswjQeQnl1NSPuv2TTyQ88+R+eicjuSYjL8GruQN9D03W5tBph5emqw5tTmkSWKFKYPJa0Jy6KOLAbnL7oneUVGCyrDsFJTJy1Vu0kCRAYje74sqdXoKhRpChf7NBgEG5OOE10eZXP4GEjp4GoxZfh/sdXrHmACTYoSocS244rB9njlpMHfIVF6fNOOlwaftoa/rmxLPMe4o++d1Llzu9r8aOkJXzlB2dnFiIR/sKV/BmvOjTpch1xw/bWPSle8xHyntl7/oSXjRyjTqNycwVDobG8H1TxUQI1yVqqTs1md70hq3+lVee7wt6kdwYDUhbo6ac4O7nDrmbxXBgQHia9Y2D2hSFWzuidw2xJwn0="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKZeQtAEo9dVvQ9wGdGphPn+2MZ5/GHO+d3JBGWBEEEOCiD83pARc5DHslILIktkz7Oyd7nGN2JpImzDTiIO5co="
      ];
      overrides = {
        user = "root";
      };
      gpgSocket = null;
    };
    "sechs-gpynq" = {
      hostname = "sechs-gpynq.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDcuRj3Q4v+46Gw9hHfT0doadEp5KlaRm2IVMOGbdGkM9zgnMwKyJhVi8/SJLtNEdSihOTa5j0711QdQ9X4obUxAe6DZf+6z8j9Qiry+SjCscQqzhrQ1V9mAufk8OEFZT/BsnTfzw5DgiodwNdf1pB9viZcNeNc3eCMbeadaR1AdU8ouBPRUR2Nap9c2HWgb0pu7irzxZCxBdEnSjkaG73qFu8Ri7NoRLFbyEDFDwdrwEi2Ri39WkS9fpa0OAeCjbeq6IdhkdLjlRB4OdhiTb59ixXS4t5U3p7Tpm5K5lNn5MqKD98lORhXrsvb1Z3FUTBi1cx3zztQtzRjzjL/k6glUUKwkJUtaYZnm5el5ebh3LyGr/GQvR40K9pNY2o7wMuEewPnNWQ0HVfjBEqX9Py9bnHCoz4u2WER8/vxfkYMEwVG5BgPFhVVUE3IYwnLEl2rE3xaJHIUN1nsHSFEO3peAM+ymNL2IPxOmy41TZ7gcyz07wUbEJYeOw1zisng1Fk="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDLbiHB5xOLkuEbdAhnvC47ZzqDbvmtD8nGjkyvSPj89G8Ti3NUBMT5aNp5vl3hRpFisKA6FyUzdyY+C+pweCZo="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIML3bhlmwfAzg9A6u/AkmuBt0zOG7AvGoO7BT9btjGK+"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "semlorasrv" = {
      hostname = "semlorasrv.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxouabVGWEnNGY/E5Ii1pU0EI6iYlvIyaYGT9dig/Y17oksUyaiXHBz7SnVA7GrNSB8zRS6O87WwCH+MgcpKCNh+nAkNa3hVRWrvcwtieT2gDuStgOJB82HIGgylic9iKBFdfEy04ujYoA+M3cCqVuBwugpNihYa3bj62aE/AgpqKLVngrWnXJTVoaWZ1srSiUDra8v87FEthj8h0ksMJ6SnwUk0/kqqm5b3doXaWxJyrHzKU0bhXOYPBJpATTLPn1V/0CbOoxhX6EJtCpUlmR6Ds17Oz9AnnKQp4eE1bJ0Ulm4CTq3TQlCvBmHLvKsYTPnG9fdlukj1jrEO3+0+osiQsWLVs5TKuRZerJBmQCsmW+htQNWEUYJU1hgiApGbq8SxyF0hgZUrBvyafSUZnCxZU/ZCMbeFBrDHBmPFCnRnWc6ANFK8GMncbOwLM8O4pg26i1GhyrrEXoMyG5VmudQFPc/YEX5qia/iSDhFhdnxvlO1/ib5z6PciBga2hJlM="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBM4ihJiIiiICtTmE33o86Xmf5Cs06QMcgCzSfr3OKbVVJhQqhMNn2mtx6qWeJTNAPlQ/U4OLiOiJAQpVs4A/960="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEi1Y//msNJL+tTfZnczcDVsHKRsEYNC1jrFuvpVF02a"
      ];
      overrides = {
        user = "root";
      };
      gpgSocket = null;
    };
    "ssd1" = {
      hostname = "ssd1.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDnlTENra9tkqdyUKy5l7GjXAyVFhCA7Q5AAsjyRkkSSweeRgM4NkBy/1kHb7j8yooEkKS1KgPKR5veWLkEe/3pVj22r8VzXH9xsZD/+6tiUWZcb6TPMTGdU8YzfUEzIO3vf8IrBCDMBJfWBFih4UvM0dcBNDqIiu+agrmn+iSeyFkvkifpFKr1BJd9MbcSNyDI+qkrJMTnqZntTnBOXSLhQnWy+Eyr+NHLRhW+h0M7ZtCshegy9zLtD/bisJBkk6IgsQHxhEy54/olhoCHZXookxEaBoubVFt42+4SWb3BdsTFHCD+t38iUAR/6/+NHU44Au9jCy/gXgTOy6KcObo9lJDxM2fSj+gUJ6u82mSsfCAr/4HTNjswZupr2/AdqTdvbNh0DvAzXk6+KmmYt96uJgTQUIclCBBdMzB+XY3kgZ4gavmTxEuyhtqDODvCEfAUEX6B1vikgTipg7JYmODgtGEarka6IDCJtwdVAXO8ObHqwqXypq0eGAj8pVbYTDc="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJW6TAuIYYXY+JpTaGOghWyKGP9Xko4BJSdM20lzBTNSol3545/c/gsLi61myLqOxYrRtMiwUpHkgZCE2DH9ESQ="
      ];
      gpgSocket = null;
    };
    "u-shift-ii" = {
      hostname = "u-shift-ii.itiv.kit.edu";
      hostkeys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMjXvezGLyj7cOSLqm8NPDxyD8z3stCE92yLGvOpsaszVdAdLnZWwopI5Zpm3sYJ1JSbLZ2tLKdMyBYcLF09USc="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD2zkk+s0QaCujx1bvA1KgppNOZBdtdZ+6/Sp3gcOZJpClJGIlKOFBFZeBjBp/Uz5BhohNxBB78TLj2TwcEkRNJf38iKTBFpCBv5kMfdt0zTxBCp3YLpZNtYK0gXydjIeXTfyun8Nh8W/Lj4/G3/lQqt32kteoaT5PEWYj1bUiu+lKouo5JWExigavVL2oWPdQ0AJO1y3i/DpTSy7n2Apmjbn8BeXVWRoIANp75kktiqO+4U1PxEsVreidK5DGTq4rjB1xDkInUWuNPgT3f8B/iyxcXLDpUCFRZLNPm2bNOt8Cm6a0WmD6dCe9RctpqrG8Q+D4LN+qJJ9yWpuDG5rvSxqJPm3PSlxG93eSI8ASHYDW3f6J1ubyg9WG+gY6ZcF8mPQpxsnTgxTCmuovUhj0YF3fcwY1UIuMwGj/mKzbIuccCAedCaVGV7FgAwM1F/bpkt1wkH8Bu+wc/64/xpFEkBf2au/6ybaxR6EoiTRuIfoRWUVDeiaOYiV1JV4YLoHs="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMwHoDUJjqImdiXcowgjJNfjvhvvh36iRRlGitrKyHHr"
      ];
      overrides = {
        user = "localadmin";
      };
      gpgSocket = null;
    };
    "virt1" = {
      hostname = "virt1.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC94mMdw2QMf+QTwG6idwAqgWWhHPDhszERF2e5FB73ZL6JwIKFLpO6O5VmsXGelg36T56CKACAIgttm/WaUUMdTE32Fie03J034CSnN4PPwsFMd0vCYZO9DsigAyhtD0kACevs3K4s+Tj17XcXeAafT4NCrZ0vZ1k3kZCO1MFCyyjRgbSD1QaipzI54OkH7BF6OSiLhIUlbODw4SHrh/9bfNqsVqmY8hwkqre4SW9JGZlP/HtzjWt6H0VRheexPftSWodHtOLKbgwF7yT+QhEvzfVhUF6L7TI9wid1mqQ9AVbP4WZR8euCP921jAtAdGkLGcI4UccTbyoiIrbOZ7PuD+ferL0hL+Fnmgx3U7CEOXyS2qY5I0FeTWUBCKQb3lvvjlWMx+JzwEoP8ijA32FfRgckTSZuBYSCRKorGXPG+03I+sXu7jCIc74lSDJZd32+Z8+sk5M983GY7TsmnsfbHN8pAWOsBOw+IC4tvJxUT5KGnCcOc53z/FQwT31cf3M="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEwYi63My/eU8SjKaPq22oiNf6DszZJQfOS7E3Kkj02+uYPiTVQxCi9fJ93CBrQKLGFskDXUG9Y3Ts3krRjMvF0="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE0W8Xxy3ovAgcBT7SiOPMPiqyqQCeKI80JV4KNt2Bor"
      ];
      overrides = {
        user = "root";
      };
      gpgSocket = null;
    };
    "virt2" = {
      hostname = "virt2.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdDugwOECOQQ73pNhEa4l/ny4Gp36dh7tPTsLIx0AToVbFtlTla5a8c9scTsMGdVHH+1oeIJ5f7hh6+Je2CiWWWVsIzT/5Rc8L84L5EBDfJrePjRgnRe6RLTgP2UgLascVgGeNLM57wq7L5amy5o/jNQGH6uz+eFuQAQ0YwHl5YxJ1WhkoJb6S98Jzf9vKsFzTy44lsXwUHQNzPfs66H1ANOLk0sx1ZAg+B4mDGWucsW/ZMhN7eHrqHTfjZIGqONunvAdmBdv+sjmuuZeNWxS4sAXibIchT49TKepabeBr1G15lnrMrT3yVszMNzNJ6J4kxN5S4wcmqbOswCkAIu7XHi3FvaTSh6cwXCHpcu0rb8fD3pauEclp5m57yWMDWmijwLfuUF4NufcPpTdMFkIHas+xMJKnrI4z0L/2CyYWhrbdbwV0rJ/CVb8wKHDe5C7p5aAsWQz31viK69I/XejwOcoze0KGSrVxgNJslymawI36X0wD4VHm2kiwfQ6WedE="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNuE9S/71FqIbrdZHXZGeQOYae/PpK6ROIkMJe7+XyZvVLiwdulvfN0RqZ7pKLzS10RqOvg8uVOVfe6iVvJo638="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG94bBNvgE0f+tilOjKfgWU2wUIaX2bo9wAg0qgWf7y7"
      ];
      overrides = {
        user = "root";
      };
      gpgSocket = null;
    };
    "virt3" = {
      hostname = "virt3.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrgYdu8jwfSYsGrH15OY9NsOcvA3prY1UncR6kdviO/u0u51Su8gqxOEnhh+jKVOC1XZU09PEZEZ+EzAhbo1qPOXKr7Da8BWhyDShGRH4pJOtfOCjOX+AfbpcSrt180GhhTEtdc7V3UJn05SdtYeMI2W6FBD5zjKjCOjjs60rJ74nnAlqTqmwVUtz1NswtUtRH4+V1yJl8So4IhgDY/H1m5tOrGXugW0qhDEpgRYcLZDyX4z0yISSrZaLJotly4xfHOxzcNtiITCbNS1/VxH4ScXR7up1qlMG5sKdHQhgfBY7F2/pftHIyEifD+MiHOAJxeqR4u2htzSkH3AxiNjxwuWMa35HkhetYdAElQs4zydJtfXInaF1qG4eezLiuWI9oQJVvMbbGEZTEedNV5Y8GbkAEFtpq6PY9t0n/bpQn36FxR7LJGb7w1JF9XxPZ4/h4cNQu+whMRpvCtUdZJ/JmUA1PpjGG3vOYFrV0WmSCYTuZLeGDNDlZXly4FVLqgvM="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNYYqLSB11z/ASRGIuME4hi7xENwoi+QOzX7bHcv7vyQ/73OfUWygDSImoBAzujTy7kZ2GzVhAGqOpjVIi3OS4w="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOid2rJlG2XvFdgfgj59Vu6BStpAOo3uNnqCA3Ino6m"
      ];
      overrides = {
        user = "root";
      };
      gpgSocket = null;
    };
    "virt4" = {
      hostname = "virt4.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCdWIa0O3cZGlpGQSIwxa26YIbD+B7/tUXBKBTVHK7YknNLNdK2NE4uYAAQ4sxZj81MpgJ+S33mS5Rst4c6LFCb2oovJyCSa+KvNm7OudP5w6u9clwLg8rg1o7VPX5S+ctiK8vEfgvVB1Wd8DRZ3veuRLsUGkKCx4dcnpjMwz2tkYvu5GzVIfzb01eHwUm7xeaYomcWLo+XznyA7Vtutt81VgPWiXtNciv8YcZsdy2omC2R3nmf0wPMouEbLC0Z0EPZfrflApurZ20aU/SBtrH4qx9fBEFIu6BYt/t9BHwdiGcf0qtPthJe+KvSwdoMhDPBkFQd8kIQD2AvNksdpXDKBMYkLhCyrOCOiLLIJ3WoI5LqKBHgBta1YNIfG4cm/HB3frRHhR7eQK78aCBn6P8pHOpzaNbY6rAtoKRhNc2/wt5q1sTTpM4GV+7z2F6hgB8uxsz2+Zf2rt0OONmPU94z40sWFQ0aXajz0UDxzrjcp08rxaOSGiaBtS7Mw5wiUsE="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBj2LmqkqXWF1WT6UKg0oNCWdgHS+xzZvQDdIQZTsfvmeWm2AUS2TpulCKeIx6nSAxnm068fCjpjo879YeItxa0="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvaxkdpYnGAiyusNnIyG4TuGrDVKboJPEA06HilV9Rb"
      ];
      overrides = {
        user = "root";
      };
      gpgSocket = null;
    };
    "workarm" = {
      hostname = "workarm.itiv.kit.edu";
      hostkeys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBD0sdYgWkABqIj1RLsvU3TZ4exeT+YvWbKK2+XjhfSAtXGQnNo3kXC8PkODmrR6HfdMTHrXumoKZUGc+KfZ150g="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDmAi3FPsLEmMtN1kl/dJMZAtILMUsT6UCqr+jc6z8Cw4mAcIL+YGY1ivZO0QFkX6/RN9X3usHEcXpVPORoVBz3MMy36pCY3eDcw4nVMo4SiqrwZ04ERKovYBM2jsNNrBVYpQ37qvhfw5dayaTz35uQywRxnYcu7qg5JEVzKl1lo09pO7yAeNzNCcr5OQhoe+mPBFqOg+N63xSoJWrEQ+TFkh4DxItjBL5jm38vqRlS4hpILY3KUxfOpwGzoiHRxTiCFgKn/a60b+Php2K8vZqe1pr48T0srKGDOianRko5GTB1kPDrqKXR/mCWhwyAZNONl+qa+a0OYbaGeWFw0xlH8iahBSJUDqra8+bRANrleq3n+vO4Ezx4XMhyyXe6v3b5aJ0zOJ+QA0kgKjwekXhDQzK1Bhd5dMc3zsGz+hbL/rzzUSqiyAN6X+JQm8o+EJnM1VbXpKnRGfUF5Bo1P9yklk2sVN9ns+I6zbLimhQ/ZcYDdbwZHbk0ADDL/kZ59qXHS+e647MUjFmotufrsuuTuJkA2RO74BPO2EFlWBJ4x7TN3q2hcsimt5P4gh4gqPk89i897Q5tfqazHKYSXaXYrh9L7AdnOJ2kxv13j0VRSB6hJq3tGqybAeQf7/KqJWNwgtZfJQ7siFxkoueXaRGPCyuEOyMsfr5tRUNjDgGhtQ=="
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7c19fYp3a90ODssk+xhyeA0+WNSATx6huXG0e8BcO0"
      ];
      overrides = {
        user = "root";
      };
      gpgSocket = null;
    };
    "workarm-sp" = {
      hostname = "workarm-sp.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDaW/U8Bi3iz/V6V8tllWOVrlvrcitgP9rHuLmxnKkDkMZXi4wF9q/vnE8XWOG2AvDJ4L3kydVZYea6K7QDS0U6pSuHDcSNSPD+5N8Pu7q+agSW9sWtzeYCc86eKA+kXin4sl3/QYffX/rlm5Sr8F7iEfmOIFQgBF+58DQFTuQZLUltCNIxe6dvAO9CUScA616i+aTXYVV9LFZlRTjfFqKHBjnpJcnWZGWEgsvLuwlDcQeqpk88sEvDXS4OFvJ37IRqJA0XcxxU0ykKCXqKinMgeUCTX4do0HC+pbYcqpB3Y2RNavaVuQ32Pe+Ky31pvkEAeG3PL35R2YlJuISyj1Lh"
      ];
      overrides = {
        user = "sysadmin";
      };
      gpgSocket = null;
    };
    "work3" = {
      hostname = "work3.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCDzLTQNazvfYQq+Sc5ZJY9g5V7uhGMwLpew36mau+ZqU19MwgMjax/A2nBfXu4LaaIKpupfWThv9piOoC6bhHhTntw3Uo/ZsNXWgD5IlYt/b0xzzKmBfYWnQ/2jyYG3hJ5cZX32gHitiWZtbpNzGrgRkEnYVpAwe0+4vfm+ifvGJyw/FjMyPT+EdD2hIyc3u41v+64Br4stNJqB/cPHrPFMIA6aP8EFL0au8SEevyEixyC8EApS7a1aBluGbQ+gNUYriE9DutjN5HLr6JYa3MG8vtmZweBmMnegMy6HhmAAZQzOH/Haa+iAyybLNEcgadENB17llN+YRZ+HGwVrnTU4Mh4SxjMgWCjblfE5rIt+/lj1/k27IrFtXujt8f7Ns3QlQYycLyfZpW3J4m/qyBed7Hwj3E6YDZvh70hZdrU0z7voWtR2nKAtWL1dQ6cjHpJgxgkCPiau64aoVUvzD6tDrBm9wOrQYdLZYQyTXOQ3jjtC3CSGjmlpsaMqhBCE3U="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeYjfgE4T3aF/4Y0OYC/O9eUdLr42CGrkrQ9Ff2dHxP"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJ/xtSP3gYcE0/pJ/3b62n3qYaQ8tN6k/sRHhGVAuM6ljCGMfWBkWuz51laPUx99Ubje41J0TUmCfVvjivaPzVE="
      ];
      gpgSocket = null;
    };
    "work4" = {
      hostname = "work4.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBHCq2KzyqXPpduvqhOu4ol1bSzrVt65n2ViqAr/UpLn8fR4oai1GD1UMNWHMij1zBWUf9g0NvTXv4sdA+0yUGFrPy+inRD57gKB+AMdG/WWP7ZHxG43OjKT34pp1O7y7AocQ1LN9tKRoylU74HJiCrob+uc9kafT2L7H3TnsB5s/paxznnU/mLgWvOsGXhuEEk4erWB5UO/EBcNDi4U7U+jscke+VUFkIEnkLXleqGg1xeHK3XURkkR3emXlTlYlkeSST9aBuUtsy735PKCM6NlJTQcDNtstt7/1sa+m7DJhu3lD6W4Ri+DtxUolC9HLotNtTZre+VNet/wP2WR60efPLTvTaNgcMneapcMxBZxInzASzBcnpBk1QVyk5p1YBxFPFlLyTLOunMSo2OMqNbwFbTaeWfPdUB173MsJLpfkvFHU3SZJFn15DPE9A+0E+wvHhxJydRpiYiKn2bfIfZZQ927nlSwa6k/ap6BYpfNdP2/zCoIZeXbg7S9hLWqU="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE01FffukxMRm04Z1Z0pbfAjlu2FR3n8Yi5O5kQP92BN"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGmzoNDGreIonmX+Ji8nigtvc7K6nRfzzILQQdCB0BIfoXgmZOSiECz7jOz3ZOyJ1mMY4PwJr1lhR0Y+WDbCgwM="
      ];
      gpgSocket = null;
    };
    "work5" = {
      hostname = "work5.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBHCq2KzyqXPpduvqhOu4ol1bSzrVt65n2ViqAr/UpLn8fR4oai1GD1UMNWHMij1zBWUf9g0NvTXv4sdA+0yUGFrPy+inRD57gKB+AMdG/WWP7ZHxG43OjKT34pp1O7y7AocQ1LN9tKRoylU74HJiCrob+uc9kafT2L7H3TnsB5s/paxznnU/mLgWvOsGXhuEEk4erWB5UO/EBcNDi4U7U+jscke+VUFkIEnkLXleqGg1xeHK3XURkkR3emXlTlYlkeSST9aBuUtsy735PKCM6NlJTQcDNtstt7/1sa+m7DJhu3lD6W4Ri+DtxUolC9HLotNtTZre+VNet/wP2WR60efPLTvTaNgcMneapcMxBZxInzASzBcnpBk1QVyk5p1YBxFPFlLyTLOunMSo2OMqNbwFbTaeWfPdUB173MsJLpfkvFHU3SZJFn15DPE9A+0E+wvHhxJydRpiYiKn2bfIfZZQ927nlSwa6k/ap6BYpfNdP2/zCoIZeXbg7S9hLWqU="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGmzoNDGreIonmX+Ji8nigtvc7K6nRfzzILQQdCB0BIfoXgmZOSiECz7jOz3ZOyJ1mMY4PwJr1lhR0Y+WDbCgwM="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE01FffukxMRm04Z1Z0pbfAjlu2FR3n8Yi5O5kQP92BN"
      ];
      gpgSocket = null;
    };
  };
  privateHosts = {
    "hydra" = {
      hostname = "hydra.catbertsen.de";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKncv408h784fugQLZFOQPer0e7fRonltCugAaCA08ME+lgroTYNzURR8Of2ohlnfFmZdQT6b0WbdnKDndHiTdjs7lp3IP08dYXRPDsc0naCxmxp6fjqunqWFFN0HgxgOuDNnBWGeNxcnda+AEKNUVV4gwLMzBP3Ql3TqBEmRzCenrlo8E/+YwfDHRjyBK9nDrVqBYidltXK9YKNFGihBWCeVO1oQBRZD2Wgk8w9NErn+LSvCvZC1lGAqwPLEBFMUTRB89cIrxEz7nAtVgPSDFkNKQ2W3BBxyl39w+p1uyB2EgL3QeHbAhiocB3vb8zFnvyfoLQkn0quEcYQEy5xCch59sgqybmhewSPcCDHc0InZFCvmT6IgnwdCUt3+Zd4DooJA12rLZ4d17tmPwQKyR1+oMi7zCyJwfi9+zmu6NSUMz6QTyU/+wIuSRklPy8Lv/V3zY6E3ESbIwa4Pa4njrkvFvY5MCN1/IB/6zVEsqOGeLo3iet+9ZLBiQ4ujGQ/dXooJgZLVXgDEQ8LG7Qh72xci0ctvGQmAqMslZxUgVfZ+B/R065gxw5Kc9cJgpipDq5uz68emZSmGPHqa+G2BWO2mDbTM8mYI4wQ/Y1UY0H9ETim35MiI1y9Lym/5PN4QQ1FbX1Qve018t6AmAmi70kbTxcL/+tGh3Yqs7n8b3uQ=="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKAcdptqXxeaqYxl4D9nXfZ+TESsif5+v7EkEql8GJWR"
      ];
      gpgSocket = "/home/christian/.forwarded-sockets/S.gpg-agent";
    };
    "alexandria" = {
      hostname = "alexandria.catbertsen.de";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCWUZ1tgwe/Q7eUT0qiIRn1oXYXi5gBMzt6k6N9XXeU1iQ35s7lPdZHKgPG8/Czrp0iU5VsG+2jasaAMgU4ahVpCqFkKxKKIfBy9L93h7t/zONvfUFwKF5RoLIB2S4S7Smj+fpQ18OJRzOf//wYDb0JlMyv5U+0RaQALQu2+AbI0urZ0V8CbR/wysZGdsYAuoJ+n+Udhgr35rfZDUteOf/dKjAZyF0wLogK6oJDLmTeFdILVp4XkSdwOeMEwAXW3s4A1gPHSP5OBDv9ChD4sZ9Arjs1jA2R12y+4yd6MiaMdriRCKtXOc8v+GTDVKAQ72GLdtZ4Wf0Tmqz53aQNOnal1Y0ckF9tUtFDUzO0dFx+3sPa1ypWkuTirUKyR5+QmKoaupRvsIAG2PtqUl9+OM6j7/rn5eRLPfDgkgideq18TREaDAuezTjsWB1ZoKyfN1HBuKtE88jpW1pngYPTbmH3DxkJpqZa/IDz6txggB2e0iLBEEYXrlLZJt5744vdusqy0f7JRtgl8uhNyeu0BH6r+ycSpFI5SrjM2fLba9EXxvQl7fK0uB1NLp0bANA91EmjwCRLmPQ+0o8m5UnCu54TDiTlRqKozC1J1Svz2ecY0jvAyqqaYiQmxGTWFifqqCcjO1c2viIrEbid4GGrBpFxoxH7uvYruutT6hmYT/1ZLw=="
        "alexandria ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/0+jHTvMJejYEduVNngIMhDi37IJ+o1dyXmTK3aORc"
      ];
      gpgSocket = "/home/christian/.forwarded-sockets/S.gpg-agent";
      overrides = {
        proxyJump = "hydra";
      };
    };
    "mannahusum" = {
      hostname = "mannahusum.catbertsen.de";
      hostkeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOPI+OGCetpSOAsUBT4U9obDBLzfApbH+4WMemD9xDq"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0uA5pX6RzBwOhBXRImMVmz6Ul0uIQPTvmLIiF7O3RZHw2p+8IukERO8iSSBmmD7wjH+lac2UqmlYnBvyWECefmUSsSVe7nF59Ksd8XCv182M0kugzvt8gatKZxSpCKNSB7zo9RWhrD74RqiZwJPqInUo7Zp4PwVwrU4MaNq4aUNxMfwlJyNvCN0XFVU+Khq0c+VhIgptr2qTRXlTGDjvNoXclO3LJ1770ImaVdaxpS4a+KXhF8kUZlmzJe+gr8zDE2kEdYX7RJvmx9rCm4eldCKoi9S9gzGfq4+Boo1q+y5ExhsvB2eifyaxW/OZ0kbNpyX7hxVxSIDZLH6Oo0QOLbA6Z+dLx4ySi/hK+2teLPJjJ2kuc391jmbNRf/kIVb6sT2NgR1mlUFA7CPIVE2n5yKQsCCIa1wEhSTqaGBRYj9X+MDL5I3HePuE1W/M8IruiQWeYF5VZ5L6Sg6rIJc5UBnuclv2ZFyfeV8OnsqHBYc2Qe3oAWsDWr3llIiOAhI0ComRcRSC4Aw782PubLzYQY8xfFGp+CfNgs9AxHJN6xnazH+nXfTZsPa/YoZdO/xNs/0KMRAlIVg9hYnCKrTn2d5l7qFwKMJPHHc77J2sUyOl+auvKyXjmK8vpzYD+yMAxMn/tDi1DBw1V2iemWXuLp63iBOi4xyV3lAmrPlEpuw=="
      ];
      gpgSocket = "/home/christian/.forwarded-sockets/S.gpg-agent";
      overrides = {
        proxyJump = "hydra";
      };
    };
    "mini" = {
      hostname = "192.168.10.249";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDjn/qTrUmmKbPbHtsjlDfdrkdqOOdIFl9Uc5qbU7q/wilu0+Jx+GWkmZK54qXJwjQmMPFrzXaP7HQGVWBHbD2IBMf3bcMzl7nzk3iZ0tNPG5BjKfe2xWohIdgUWdva0JOlI46fAZKN11Zc4H/4TnXCDS8SwQqyNcAjU8t768vpAfPTTNnE2iYDIJCXsz9Xh3bpHvYd7z8pUB4Zk5TM95bjh2A+bwiQXeYU/ooYEHl3fDmjIWJeQm00CwO1BD4EsvJCRkIzZ0Zjd0P3bzn3dyl5VxKno0V7SWsp/95UCeZm+C7wr/S0NYtLKZ6lWI+fVJRBN1Azh675EMlatxYTCSiTfjlOuCUh47L0Ikqq39Ev6a5nr7VuTc517f3pSyUmPSgKvV3aAZ2aVDIU+RWTUGZFEgonoQo+FUqFUaaR0afMu8ZWBQFpt6OwjgCxIWkvWoub+mG3ZtMWWbrrcGzWOkT7wt7664fEpKHup+zG+5IGZg4Owv3G0mHLqaPnmPk/G50="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBdmI9JovLniVi+D6hIyIeWC1/6RRV5JMK99GwbhBsMGC/pJLW+8nGzypngKRV0RRRijipnoGE2W56TYZjrjLwk="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFOu4nY103HxCCz5UuCokCcUM1tsKpDLMANo5gNOc4Jn"
      ];
      gpgSocket = "/home/christianalbertsen/.forwarded-sockets/S.gpg-agent";
      overrides = {
        proxyJump = "hydra";
        user = "christianalbertsen";
      };
    };
  };
  cfg = config.ca.ssh;

  known_hosts_for = file_extension: hosts_config:
    pkgs.writeText file_extension (strings.concatLines (builtins.concatLists (
      builtins.map (
        values:
          builtins.map (
            key: "${values.hostname} ${key}"
          )
          values.hostkeys
      ) (builtins.attrValues hosts_config)
    )));
  privateKnownHost = known_hosts_for "known_hosts_ca" privateHosts;
  itivKnownHosts = known_hosts_for "itiv_known_hosts" itivHosts;

  identityFiles = map (builtins.toFile "key.pub") pkgs.al_public_keys;

  host-config = defaults: host: socket: value: (
    let
      remoteSocket =
        if hasAttr "gpgSocket" value
        then value.gpgSocket
        else "/home/to6338/.forwarded-sockets/S.gpg-agent";
    in
      {
        inherit host;
        inherit (value) hostname;
      }
      // (
        if (socket == null) || (remoteSocket == null)
        then {}
        else {
            RemoteForward = "${remoteSocket} ${socket}";
        }
      )
      // defaults
      // (
        if hasAttr "overrides" value
        then value.overrides
        else {}
      )
  );

  standard-config = {
    identitiesOnly = true;
    identityFile = identityFiles;
    forwardAgent = true;
    forwardX11 = true;
    forwardX11Trusted = true;
  };

  itiv-host = host-config (standard-config
    // {
      user = "to6338";
    });

  private-host = host-config (standard-config
    // {
      user = "christian";
    });

  configure-hosts = hostconfig: socket:
    mapAttrs (
      name: value:
        hostconfig name socket value
    );
in {
  options = {
    ca.ssh = {
      enable = mkEnableOption "Generate SSH configuration";
      localGpgSocket = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Local location of the GPG socket
        '';
      };
      forwardGpgSocket = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Forward the socket to the remote host
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      NIX_SSHOPTS = "-o ControlMaster=no -o ClearAllForwardings=yes";
    };
    ca.bash.extraProfile.ensureXauth = ''
      [ -e "$HOME/.Xauthority" ] || touch "$HOME/.Xauthority"
    '';
    programs.ssh = {
      extraConfig = ''
        XAuthLocation ${pkgs.xauth.out}/bin/xauth
      '';
      enable = true;
      enableDefaultConfig = false;
      settings = let
        toGpgSocket =
          if (cfg.forwardGpgSocket && (cfg.localGpgSocket != null))
          then cfg.localGpgSocket
          else "/run/user/1000/gnupg/S.gpg-agent";
      in
        (configure-hosts itiv-host toGpgSocket itivHosts)
        // (configure-hosts private-host toGpgSocket privateHosts)
        // {
          "*" = {
            controlPath = "~/.ssh/master-%C";
            controlMaster = "yes";
            userKnownHostsFile = "~/.ssh/known_hosts ${privateKnownHost} ${itivKnownHosts}";
            forwardAgent = false;
            addKeysToAgent = "no";
            compression = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            controlPersist = "no";
          };
        };
    };
  };
}
