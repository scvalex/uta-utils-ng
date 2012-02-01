/**
 * Name: diffu
 * Description: unified diffs (with added java)
 * Author: buchal@ifh.bau-verm.uni-karlsruhe.de
 */

state java_oneline extends HighlightEntry
{
  /* Comments. */
  /\/\*/ {
    comment_face (true);
    language_print ($0);
    call (c_comment);
    comment_face (false);
    return;
  }
  /\/\// {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
    return;
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
    return;
  }

  /* Character constants. */
  /'.'|'\\\\.'/ {
    string_face (true);
    language_print ($0);
    string_face (false);
    return;
  }

  /* Keywords.
     (build-re '(abstract boolean break byte case catch char class
     const continue default do double else extends false final finally
     float for goto if implements import instanceof int interface long
     native new null package private protected public return short static
     super switch synchronized this throw throws transient true try void
     volatile while))
  */
  /\b(abstract|b(oolean|reak|yte)|c(a(se|tch)|har|lass|on(st|tinue))\
|d(efault|o(|uble))|e(lse|xtends)|f(alse|inal(|ly)|loat|or)|goto\
|i(f|mp(lements|ort)|n(stanceof|t(|erface)))|long|n(ative|ew|ull)\
|p(ackage|r(ivate|otected)|ublic)|return\
|s(hort|tatic|uper|witch|ynchronized)|t(h(is|row(|s))|r(ansient|ue|y))\
|vo(id|latile)|while)\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
    return;
  }
}

state diffu extends HighlightEntry
{
  BEGIN {
    old_face = make_face (font, 0, 0);
    old_face[bg_color] = language_color("gray95");

    my_heading = make_face (bold_font, 0, 0);
    my_heading[bg_color] = language_color("gray75");
  }

  /^\@\@/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /^-/ {
    face_on (old_face);
    language_print ($0);
    call (eat_one_line);
    face_off (old_face);
  }

  /^+/ {
    language_print ($0);
    call (java_oneline);
  }

  /^[^\ ]/ {
    string_face (true);
    language_print ($0);
    call (eat_one_line);
    string_face (false);
  }

  /^(---|+++)/ {
    face_on (my_heading);
    language_print ($0);
    call (eat_one_line);
    face_off (my_heading);
  }
}


/*
Local variables:
mode: c
End:
*/
