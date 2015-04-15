# **ghvandalism**

## *Github History Vandalism bash automated*

## Intro

Similar to [Gitfiti](https://github.com/gelstudios) and [Pokrovsky](http://pokrovsky.herokuapp.com/), this does the same.

Text decorate your github account's commit history calendar by (blatantly) abusing git's ability to accept commits in the past, and in effect, creating a text-based graffiti.

**Example screenshots:**

![](https://www.evernote.com/shard/s479/sh/48cb6dd5-872d-440b-a0b3-81d9b3b0ec10/4f4d50637ba74824ba55c365c6f0f981/deep/0/timhtheos-(Timothy)---GitHub.png)
![](https://www.evernote.com/shard/s479/sh/91d78147-eda8-4651-8612-678590ccf46e/780a094378f36db0e7532b9c76092fb8/deep/0/timhtheos-(Timothy)---GitHub.png)

## Background History

[Gelstudios](https://github.com/gelstudios)' [Gitfiti](https://github.com/gelstudios/gitfiti) is written in python.  You have to fork it locally, and then run `gitfiti.py` and manually provide your github credentials there to generate commits.

[Pokrovsky](http://pokrovsky.herokuapp.com/) is a web service that provides web API to generate a bash file that can be ran locally. It owes a lot from Gitfiti.

#### Limitations
1. With gitfiti, it's python dependent, and you have to type your credentials each generate of the graffiti.
2. With Pokrovsky, it's much easier, but it does not (same with gitfiti) create and delete github repositories.

#### Solution
Automation - where both of them ends, this script begins.
1. You supply your github credentials.
2. This will pull Auth Token via github dev API with permission to create `repo` and `delete_repo`.
3. This creates a repository in your github account, as well as deletes it when you generate new graffiti.
4. This uses Pokrovsky web service. I opt to use this service vs using the original gitfiti.

## Use Case

After you vandalised your github history using either of the abovementioned, you will soon realize that as days and weeks pass by, the `graffiti` is cut off at the left part of it - because it's moving to the left direction, as it is crafted in commits history and history is growing old as time and days pass by.

To update the graffiti, you need to delete the repository, and create a new one, and generate new commits containing dates that form the new `graffiti`.

This script automates it with a `config.info` file that is ignored in git's `.gitignore` file.  So you should not bother yourself with this file.

## Dependencies

Unfortunately, I was not able to write pure bash to handle the automation.  This shell script uses the following, as dependency:

1. curl
2. **jq** - is a lightweight and flexible command-line JSON processor.  For installation, go to their [website](http://stedolan.github.io/jq/)'s [download](http://stedolan.github.io/jq/download/) page.

## How to use
1. Clone this repository
  ```
  git clone --depth=1 git@github.com:timhtheos/ghvandalism.git
  cd ghvandalism
  ```

2. Edit config.info file and provide your github username, password and repository.
  ```
  # Github login
  user="timhtheos"
  pswd="myPassword2015"
  
  # Github repository (must be non-existing)
  repo="fake101"
  ```
  
  The `user` shall be the user as displayed in the URL, and not your email address.

  The repository may exist, but it is recommended to provide a repository that does not exist yet. This is important should you provide an existing repository, it will be deleted in github, and it cannot be undone.

3. Run `install.sh` file, and provide the first argument which serves as the text graffiti to be generated
  ```
  bash install.sh <arg1>
  ```

  `<arg1>` shall be the text to convert into graffiti, e.g.
  ```
  bash install.sh ILOVEU
  ```

  The text shall not exceed 6 characters.  If you provide more than 6 characters, it won't throw an error, but the 7th and up will not appear in the graffiti.

  If you provide 2 words, such as `@ 2015`, have them double quoted, e.g. **"@ 2015"**.  Also please note that a space ` ` is counted as one character.

4. To change the text graffiti, just do step 3 again.

## Credits
* [Gelstudios](https://github.com/gelstudios)' [Gitfiti](https://github.com/gelstudios/gitfiti)
* [Pokrovsky](http://pokrovsky.herokuapp.com/) web service
* and the one who introduced me to gitfiti
