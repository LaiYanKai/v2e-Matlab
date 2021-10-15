# v2e-Matlab
A Matlab implementation of v2e, with limited modifications. It does not include SlowMo interpolation as in the original work by the authors. The work is compared to a Python (Google Colab) version of v2e by the authors.
The PDF is rushed, so may contain many typos, but contain essential information about concepts, data and results.

One advantage over v2e's implementation include the interpolation (ad-hoc uniform random) of asynchronous shot noise events between the timestamps of two adjacent frames.
Additionally, if there are multiple events between these frames, each event fires evenly between these frames depending on the log luma values sampled at both frames.
These events appear to occur regularly between frames and not asynchronously in the authors' Python implementation. This may have been a bug, or that the slow motion interpolation is fast enough to eliminate the need to implement asynchronously (but only assuming if the user chooses slow motion interpolation).

Some samples can be seen here:
The Youtube playlist of the videos in the repository can be found here: https://www.youtube.com/playlist?list=PLDpF71gHb-Wo0nfRfRtL4Ek433ZI9EOmK
The videos are not clear but gives us a quick glance of the results.

For the snippets below, the left panel shows the source video; the middle shows the v2e Python (authors') results; and the right shows this work's Matlab implementation.
Snippet of dot_comb


https://user-images.githubusercontent.com/28682226/137457643-b8363f7b-49ab-4ede-a2f2-c65840352363.mp4


Snippet of lego_comb


https://user-images.githubusercontent.com/28682226/137457665-295605c0-b350-43ec-a1b0-fb9762c59dce.mp4


Snippet of faucet_comb


https://user-images.githubusercontent.com/28682226/137457737-f2b120d6-b663-46ef-bf37-2b2daf8bcbdc.mp4


The asynchronous interpolation advantages can be seen in the video below:
960FPS --> 5000FPS (snippet of lego_comb_clean_interp). Letf panel is from v2e Python. Right is from the current work.


https://user-images.githubusercontent.com/28682226/137457766-bb28e514-b5f4-4ace-a81a-351499c893ea.mp4


It may be possible to use optical flow methods in the slow motion interpolation to interpolate the resulting noise events directly.
