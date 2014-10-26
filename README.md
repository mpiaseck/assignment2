In the second assignment, you have a choice of two projects; a simple one-measure sequencer, or a looping playback engine.

1 Choice 1: Simple Sequencer

The simple sequencer allows the user to toggle lights in a grid to create a small looping piece of music.

More specifically, the grid should be 8 columns wide; each column represents an "eighth" note. If you’re counting off a measure, this includes "one, and, two, and, three, and, four, and" — eight notes. Each row represents a particular sample or sound.

The sequencer plays continuously, at a tempo of your choice. As each eighth note rolls around, the sequencer plays all of the sounds whose lights are toggled on. So, if it happens to be time to play the "and" of three (column six), and the lights in the fourth and seventh rows of column six are illuminated, then those two sounds should be played.

It’s your task to implement the sequencer, and also to choose the samples associated with the rows. You can use built-in drum sounds and built-in tone sounds, but a more creative team will discover their own samples. Also, splitting a measure of an existing song into eight parts will provide interesting samples that can be used for eight rows.

You’ll probably get a *lot* of nasty-sounding clipping if you play all of your sounds at top volume. For this assignment, you should probably scale your sounds down using "rs-scale" so that adding them together doesn’t cause clipping. You can experiment with the amount of scaling required.

If you like, you can extend the assignment. You could provide a special button that resets the panel, for instance, or saves a pattern to be restored later.

2 Choice 2: looping playback engine

A looping playback engine contains at least four separate pieces of music, and allows the user to play all of them simultaneously, and to reset the playheads independently to allow the user to synchronize or mess up the songs.

So, for instance, there might be four long bars, and four toggle buttons to turn playing of the sounds on and off independently. Clicking on one of the bars might set the playhead of that individual sound to the corresponding location. All of the samples that are playing should loop back to the beginning when they’re done.

You can also think of lots of other interfaces; it might make sense to have the bars control the *relative* playback positions of the loops, so that you can more easily align them. Alternatively, you might be able to set independent start and stop loop points, so that you can control the lengths of the loops. Once again, the sky’s the limit!

3 Hints

Don’t go overboard. Use Incremental Development. Start with something *simple*. Add bells and whistles after getting something working.

4 Team Work

The best teams will work effectively together. This means *communicating*! You should make a plan, and make sure that everyone knows what it is. If you’re having trouble with a part of the project, let your team know! Keeping everyone in the loop is the best way to avoid problems. This project is a warm-up for the final project, so now’s the time to get things ironed out. Arrange a meeting time as soon as possible!

Also, I will be asking you later on in the quarter to assess the contribution of each of your teammates to the project, so make sure that you’re responsible for your parts of the project.

5 Final Submission

Like the previous project, this project will consist of two separate handins; the .zip bundle containing the code and samples for the project, and a portfolio writeup of the project.

As before, only one team member needs to submit to PolyLearn.

As before, *every* member must upload materials to his or her own portfolio.

The bundle you submit to PolyLearn should contain all of the code and samples required to run the project, and the main racket program should be in a file called "project-2.rkt". This bundle does not need to contain any of the "portfolio" parts of the assignment; just enough to make it run. Only one member of the team needs to submit the project bundle. Submit it using the Project 2 handin using PolyLearn. If more than one member submits, I will ignore all but the last submission.

As before, your portfolio should contain your code, a one-paragraph writeup, and a short recording of the project.

The one-paragraph writeup should describe how you chose your samples, what extras (if any) you added to the project, and how the project works.

Your recording—ideally, a video recording—should be about 30 seconds, and should show the primary features of the program.

It’s fine for every team member to use the same paragraph and recording.

6 Grading Rubric

The grading for this assignment will be as follows:

5 PolyLearn bundle handed in

5 Coherent and legible code

5 Portfolio updated for assignment 2

4 coherent and legible paragraph

3 recording/screenshots

2 “above and beyond” points for additional creative effort

7 Help!

If you need help, I strongly advise you to post to the Piazza group rather than contacting me directly: I’ll respond to both, and that way others can see your questions. Often, you’ll get a good answer more quickly from someone other than me.

8 Sharing Code

Naturally, you’ll be sharing all of your code with the rest of your team. There are a number of nifty ways to do that, including GitHub and other public repo tools.

Beyond that, though, you’re welcome to use other teams’ code, with proper attribution. So if the PowerSheep come up with a really cool sound, it’s fine with me if you use it in your program, indicating the chunk of code that came from the PowerSheep.
