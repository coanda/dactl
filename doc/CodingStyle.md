Dactl Coding Style
==================

The coding style to respect in this project is very similar to most
Vala projects. In particular, the following rules are largely adapted
from the Rygel Coding Style.

 * 4-spaces (and not tabs) for indentation.

 * ''Prefer'' lines of less than <= 120 columns

 * 1-space between function name and braces (both calls and signature
   declarations)

 * Avoid the use of 'this' keyword:

 * If function signature/call fits in a single line, do not break it
   into multiple lines.

 * For methods/functions that take variable argument tuples, all the
   first elements of tuples are indented normally with the subsequent
   elements of each tuple indented 4-space more. Like this:

        action.get ("ObjectID",
                        typeof (string),
                        out this.object_id,
                    "Filter",
                        typeof (string),
                        out this.filter,
                    "StartingIndex",
                        typeof (uint),
                        out this.index,
                    "RequestedCount",
                        typeof (uint),
                        out this.requested_count,
                    "SortCriteria",
                        typeof (string),
                        out this.sort_criteria);

 * ''Prefer'' descriptive names over abbreviations (unless well-known)
   & shortening of names. E.g discoverer over disco.

 * Use 'var' in variable declarations wherever possible.

 * Use 'as' to cast wherever possible.

 * Single statments inside if/else must not be enclosed by '{}'.

 * The more you provide docs in comments, but at the same time avoid
   over-documenting. Here is an example of useless comment:

   // Fetch the document
   fetch_the_document ();

 * Each class should go in a separate .vala file & named according to
   the class in it. E.g Dactl.PolarChart class should go under
   dactl-polar-chart.vala.

 * Avoid putting more than 3 'using' statements in each .vala file. If
   you feel you need to use more, perhaps you should consider
   refactoring (Move some of the code to a separate class).

 * Declare the namespace(s) of the class/errordomain with the
   class/errordomain itself. Like this:

        private class Dactl.Hello {
        ...
        };

 * Prefer 'foreach' over 'for'.

 * Add a newline to break the code in logical pieces

 * Add a newline before each return, throw, break etc. if it
   is not the only statement in that block

        if (condition_applies ()) {
            do_something ();

            return false;
        }

        if (other_condition_applies ())
            return true;

   Except for the break in a switch:

        switch (val) {
            case 1:
                debug ("case 1");
                do_one ();
                break;

            default:
                ...
        }

 * If a function returns several equally important values, they should
   all be given as out arguments. IOW, prefer this:

        void get_a_and_b (out string a, out string b)

   rather than the un-even:

        string get_a_and_b (out b)
