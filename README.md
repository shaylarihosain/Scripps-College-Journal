# Scripps College Journal Design

Introduces designers to Scripps College Journal's design and brand system, and prepares their computer automatically.

Boasting tight integration with Adobe Creative Cloud, it installs fonts, configures InDesign’s layout, and shows designers around the latest available SCJ brand guides.

Upon the designer’s request, it creates final packages for print (and web) that are formatted correctly for our print house, with appropriate color management and image resolution, all automatically.

The app can update the brand guides on the design team's computers when newer ones are available, update itself with bug fixes and new features, and download Creative Cloud when it's not already installed.

[Download it here](https://github.com/shaylarihosain/Scripps-College-Journal/releases/download/0.7/InstallScrippsCollegeJournal.dmg).

![SCJ](https://user-images.githubusercontent.com/74567503/116485561-63c28d80-a840-11eb-93f1-52f50148abf6.jpg)

# Installation

Open the downloaded installer on your Mac.

1. Drag _Scripps College Journal_ into _Applications_.

2. Open the _Applications_ folder, and open the SCJ app. You’ll see a warning. Click _Cancel_.

3. Open _System Preferences_, and go to _Security & Privacy_.

4. In the _General_ tab, click the _Open Anyway_ button near the bottom.

**Running for the first time**

For the app to work, please grant access when your Mac prompts you. It will ask about Finder, System Events, Preview, InDesign, and Documents.

The first time it runs, it will download the design guides.

# Features

- **Updates existing SCJ brand design guides to the newest ones**

- **Installs our latest brand fonts**

- **Injects more convenient custom Adobe InDesign interface layout tailored to magazine design**

- **Moves the issue's artwork into the correct folder**
     - When leadership sends you the visual artwork selected for use in the _Journal_, you need to put it into the Artwork folder. (We all work with one set of artwork that was accepted for this year's issue. When we split up the issue for multiple designers to work on, we don't need to repackage the artwork every time.) 
     - With the _Scripps College Journal_ app, you can drag all the images you download onto its Dock icon, and it'll move those files to the correct folder automatically, so that when you export the PDF, the links will be intact for the senior designer, who combines everyone's work.

- **Automatic magazine export** (Beta, some features may not be functional or operating correctly for now) 
     - When you're done with your pages, drag the InDesign file onto the SCJ Dock icon, and click _Package for Senior Designer_. You'll have the option to email the created files. (Currently only exports preview PDF)
     - When you're done with the magazine, drag the InDesign file onto the SCJ Dock icon and the magazine will be packaged automatically with properly formatted, sized and colored print PDFs that matches our print house's specifications, a PDF suitable for digital viewing, the InDesign .indd file, and an .idml XML archive file for InDesign CS4. (Not functional right now)
     - Cuts down or completely eliminates diagnosing and rectifying print proofing errors. Preserves institutional memory, so that information on preparing files for Claremont Print is not lost.

- **Install Adobe Creative Cloud**
     - If you don't have Creative Cloud installed, _Scripps College Journal_ will download it for you.

- **Auto-updating compatibility rules**
     - If each member of the design team uses different versions of InDesign, the work they create will not be compatible. To prevent this issue from occurring, _Scripps College Journal_ will notify users with out-of-date InDesign installations before letting them start, and provide them with clear instructions on how to rectify the issue. Each year, the app will keep team members on the same version automatically.

- **For senior designers**
     - When deploying a new design guide, the _Assets Version_ file and the _Assets_ zip folder here on GitHub, and the _SCJ Design Version_ file in the zip itself all need to be updated. After updating these attributes in this repository, the app downloads the newest guides on your design team's computers. In the _Assets_ folder, the app will use whatever font files exist in the fonts folder, and whatever version of the design guide is present.
     - (Beta) Signing in as a managing editor in the app will disable Adobe and macOS compatibility checks on that machine. Use at your own risk.

# System requirements
macOS Mojave or later  
Adobe Creative Cloud 2021  
2 GB of free space recommended, 0.2 GB required

_These requirements will automatically change every year starting in 2023 until 2027_

# FAQ
**I'm on Windows. How do I access the design system?**

Unfortunately, we don't have an app for Windows. On a PC, download the _Assets.zip_ package.

Everything you need to build Scripps College Journal, including our InDesign and Illustrator brand guides, font files, PDF export presets, and InDesign workspace is still included.

You will have to open each file manually. For example, you'll drag the issue's artwork into the Artwork folder using Windows Explorer, install the included fonts on your PC by right-clicking on them, and export your final PDFs using InDesign's standard export dialog. Because there is no app to mandate any Adobe compatibility rules, please speak with a member of your team to ensure you use the correct versions of InDesign and Illustrator.

(Note: On Windows, be sure to install the included SCJ-specific PDF export presets before exporting any PDFs. This is absolutely mandatory if you are creating a final print file, so that the magazine prints correctly.

On a Mac, the SCJ app does this all for you automatically. It imports the PDF presets automatically as you use it, and it exports the magazine automatically using the correct color profile, resolution and format for our print house.)

**How do I make sure I have the latest version of the design guides?**

The app notifies you on startup if the design guides you have are older, and you'll be given the option to update them. To check their status, click the _About_ button on the main _Welcome_ screen.

###### ————————————————————

###### Unauthorized copying or reproduction of any part of the contents of this repository, including code, binaries, disk images, or Scripps College Journal logotypes, brand assets and design guides, via any medium, is strictly prohibited. 
###### © 2019–2021 Shay Lari-Hosain. All rights reserved.
