UTA-Utils-ng
============

> automating marking since 2012!

How to run
----------

Run the `auto-marker.sh` script with two arguments: the name of the
exercise (actually, the name of the master git repo) and the logins of
the students as a string.

    % auto-marker.sh TurtleInterpreter "dd1711 tod11 jdl11 omm11 mpn10 jr1611 pjr11 yx2411"

This will create a folder with the exercise name, clone/pull the
stdents' git repos into it, generate a bunch of reports in the
top-level folder, and combine all the reports into files named
`<login>-combined.pdf`.

Reports generated
-----------------

- Code in changed `.java` files,
- `checkstyle` warning for the changed files.
