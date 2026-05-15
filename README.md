<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->

<a id="readme-top"></a>

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/LoveDoLove/SuperGit-Tools">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">SuperGit-Tools</h3>

  <p align="center">
    A powerful suite of automated Git synchronization tools for Windows, featuring safer v4 CLI/GUI rewrites and Friendly Horizon-inspired PowerShell tooling for managing multiple repositories with ease.
    <br />
    <a href="https://github.com/LoveDoLove/SuperGit-Tools"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/LoveDoLove/SuperGit-Tools">View Demo</a>
    &middot;
    <a href="https://github.com/LoveDoLove/SuperGit-Tools/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    &middot;
    <a href="https://github.com/LoveDoLove/SuperGit-Tools/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
     </li>
     <li><a href="#usage">Usage</a></li>
     <li><a href="#ai-long-term-memory--skills">AI Long-Term Memory & Skills</a></li>
     <li><a href="#roadmap">Roadmap</a></li>
     <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

SuperGit-Tools is designed to solve the headache of managing multiple local Git repositories. Whether you have 5 or 50 projects, keeping them all synchronized can be tedious. This project provides two powerful tools to automate this process:

1.  **`git-sync-gui-v4.ps1` (v4.0)**: A rewritten Friendly Horizon GUI aligned with the safer v4 sync flow, live logs, recursive discovery, and clearer repository state reporting.
2.  **`git-sync-v4.ps1` (v4.0)**: A safer CLI rewrite for recursive discovery and ff-only synchronization.
3.  **Legacy scripts**: `git-sync-gui.ps1` (v3.0) and `git-sync.ps1` (v1.0) remain in the repository for compatibility.

**Key Features (GUI v4.0):**

- **Auto-Discovery**: Recursively scans folders to find Git repositories.
- **Real-Time Status**: Instantly see if repos are Clean, Dirty, Ahead, Behind, or Diverged.
- **Modern UI**: Friendly Horizon-inspired light interface focused on operational clarity.
- **Safer Sync**: Uses `git fetch --all --prune` and `git pull --ff-only`.
- **Parallel Backend**: Rewritten core logic with parallel status and sync workers for smoother large-folder operations.
- **Live Logs**: Streams operation logs directly in the GUI.
- **Targeted Actions**: Sync all repositories or only the selected rows.
- **Settings Persistence**: Remembers recent folders and scan depth.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

- [![PowerShell][PowerShell]][PowerShell-url]
- [![Dotnet][Dotnet]][Dotnet-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

- **Windows OS**: The tools are designed for Windows.
- **PowerShell 5.1+**: Pre-installed on most Windows systems.
- **Git**: Must be installed and available in your system PATH.
  ```sh
  git --version
  ```

### Installation

1.  Clone the repository
    ```sh
    git clone https://github.com/LoveDoLove/SuperGit-Tools.git
    ```
2.  Navigate to the directory
    ```sh
    cd SuperGit-Tools
    ```
3.  Ready to run! No additional dependencies are required as it uses standard .NET libraries available in PowerShell.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->

## Usage

### GUI Application

Run the rewritten GUI script to launch the visual interface:

```powershell
.\git-sync-gui-v4.ps1
```

- **Browse Folder**: Choose the root folder containing your projects.
- **Scan Repositories**: Recursively discover repos and compute current status.
- **Sync All / Sync Selected**: Run the safer v4 sync flow from the GUI.
- **Options**: `Include Dirty Repos`, `Dry Run`, and `Fetch Only`.

### CLI Tool

Run the CLI script for a text-based interactive experience:

```powershell
.\git-sync.ps1 -ParentFolder "D:\Projects"
```

New CLI rewrite (v4, safer + recursive discovery):

```powershell
.\git-sync-v4.ps1 -RootFolder "D:\Projects" -AutoConfirm
```

- `-AutoConfirm`: skip per-repo prompt
- `-IncludeDirty`: allow syncing repos with uncommitted changes
- `-DryRun`: preview only, no git changes
- `-FetchOnly`: only fetch, no pull

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->


## AI Long-Term Memory & Skills

### AI Long-Term Memory Mechanism

| Level | File Location | Content |
|---|---|---|
| Long-term memory | `MEMORY.md` | User preferences, project goals, persistent conventions |
| Daily log | `memory/YYYY-MM-DD.md` | Daily AI work records, decisions, and notes |
| Task tracking | `memory/tasks.md` | Cross-session todo/progress tracking |
| Skill assets | `.agents/skills/` | Installed and reusable AI Agent skill packages |

### AI Agent Skill Packages

Skill packages are reusable AI capabilities organized under `.agents/skills/<skill-name>/`, with `SKILL.md` as the primary entry.

Built-in package:
- `karpathy-guidelines`: behavioral guidelines to reduce common LLM coding mistakes.

Skill workflow:
1. On task intake, check local `.agents/skills/` first and reuse existing packages.
2. If no suitable local package exists, search GitHub open-source repositories or Skills.sh.
3. Install under `.agents/skills/<skill-name>/` and update `.agents/skills/INDEX.md`.

Policy:
- All skill packages must be sourced from GitHub open-source repositories (not self-authored local rewrites).


## Roadmap

- [x] **Settings Persistence:** JSON-based settings for user preferences.
- [x] **Recent Folders:** Quick access to recently used paths.
- [x] **Multi-threading:** Optimized parallel status checking.
- [ ] **Repository Details:** Detailed view for recent commits and file changes.
- [ ] **Scheduled Sync:** Background auto-sync at configurable intervals.
- [ ] **Advanced Git:** Branch switching and stash management directly from UI.

See the [open issues](https://github.com/LoveDoLove/SuperGit-Tools/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

**LoveDoLove**

- Discord: [Join Server](https://discord.com/invite/FyYEmtRCRE)
- Telegram: [Official Channel](https://t.me/lovedoloveofficialchannel)
- GitHub: [LoveDoLove](https://github.com/LoveDoLove)

Project Link: [https://github.com/LoveDoLove/SuperGit-Tools](https://github.com/LoveDoLove/SuperGit-Tools)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments

- [Best-README-Template](https://github.com/othneildrew/Best-README-Template)
- [Shields.io](https://shields.io)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/LoveDoLove/SuperGit-Tools.svg?style=for-the-badge
[contributors-url]: https://github.com/LoveDoLove/SuperGit-Tools/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/LoveDoLove/SuperGit-Tools.svg?style=for-the-badge
[forks-url]: https://github.com/LoveDoLove/SuperGit-Tools/network/members
[stars-shield]: https://img.shields.io/github/stars/LoveDoLove/SuperGit-Tools.svg?style=for-the-badge
[stars-url]: https://github.com/LoveDoLove/SuperGit-Tools/stargazers
[issues-shield]: https://img.shields.io/github/issues/LoveDoLove/SuperGit-Tools.svg?style=for-the-badge
[issues-url]: https://github.com/LoveDoLove/SuperGit-Tools/issues
[license-shield]: https://img.shields.io/github/license/LoveDoLove/SuperGit-Tools.svg?style=for-the-badge
[license-url]: https://github.com/LoveDoLove/SuperGit-Tools/blob/master/LICENSE
[PowerShell]: https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white
[PowerShell-url]: https://microsoft.com/powershell
[Dotnet]: https://img.shields.io/badge/.NET-512BD4?style=for-the-badge&logo=dotnet&logoColor=white
[Dotnet-url]: https://dotnet.microsoft.com/
