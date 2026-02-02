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
    A powerful suite of automated Git synchronization tools for Windows, featuring a robust CLI script and a modern, aesthetically pleasing WPF GUI (Friendly Horizon v3.0) for managing multiple repositories with ease.
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

1.  **`git-sync-gui.ps1` (v3.0)**: A comprehensive GUI application built with PowerShell and WPF. It features the "Friendly Horizon" light theme, real-time status updates, asynchronous operations, and a rich set of management features.
2.  **`git-sync.ps1` (v1.0)**: A clean, automation-focused CLI script for users who prefer the terminal.

**Key Features (GUI v3.0):**

- **Auto-Discovery**: Recursively scans folders to find Git repositories.
- **Real-Time Status**: Instantly see if repos are Clean, Dirty, Ahead, Behind, or Diverged.
- **Modern UI**: Beautiful "Friendly Horizon" design with card-based layout and visual feedback.
- **Async Operations**: All Git checks and syncs run in the background, keeping the UI responsive.
- **Search & Filter**: Filter by status (e.g., "Show only Dirty repos") or search by name.
- **Settings Persistence**: Remembers your preferences and recently used folders.
- **Statistics Panel**: Quick overview of your repository health.

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

Run the GUI script to launch the visual interface:

```powershell
.\git-sync-gui.ps1
```

- **Select Folder**: Choose the root folder containing your projects.
- **Sync All**: Click "Sync All" to fetch and pull updates for all displayed repositories.
- **Context Menu**: Right-click any repository card to Sync, Refresh, Open in Explorer, or Copy Path.
- **Shortcuts**: `Ctrl+F` (Search), `Ctrl+R` (Refresh), `Ctrl+S` (Sync All).

### CLI Tool

Run the CLI script for a text-based interactive experience:

```powershell
.\git-sync.ps1 -ParentFolder "D:\Projects"
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->

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
