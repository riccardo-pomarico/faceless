Server.default.options.numInputBusChannels=0;
s.boot;


// ==========
// Synth
// ==========


// Run this block once (it creates the synth)
(

TempoClock.default.tempo = 0.5;

SynthDef("spacey", { arg freq, amp, cutoff = 0;
	var snd, env;
	var cutoff_freq;
	var fil_osc;
	env = Env.perc(level: amp/8).kr(2);
	snd = LFSaw.ar(freq: freq, mul: env);
	snd = RLPF.ar(
		in: snd,
		freq: LFNoise1.kr(2).range(500, 20000),
		rq: 0.2
	);

	cutoff_freq=((cutoff+0.5)*6)*freq;

	fil_osc=BLowPass.ar(in:snd, freq:cutoff_freq.min(20000));

	Out.ar(0, snd);
}).add;

// ==========
// Patterns
// ==========


// putting it all together
// note the use of Pbindef (a variation of Pbind that allows you to re-run the code in real time without stopping the sound)
Pbindef(\wow,
	\instrument, "spacey",
	\midinote, Pseq([
		// bass run
		Prand([\rest, Pseq([24, 30, 31, 43, 47, 48])]),

		// middle part (plays twice)
		Pseq([60, Prand([64, 66]), 66, Prand([71, 72, 74])], 2),

		// ending melody of 3 to 9 notes
		Prand([74, 76, 78, 79, 81], rrand(3, 9))
	], inf),
	\dur, 0.2,
	\amp, 0.25
).play;

// Adding some reverb
Ndef(\rev).play;

// Reverb 1
Ndef(\rev, { ReplaceOut.ar(0, Limiter.ar(Mix(FreeVerb.ar(In.ar(0), mix: 0.4, room: 0.9)))) }).play;

// Reverb 2
Ndef(\rev, {
	var snd = In.ar(In.ar(0));
	6.do({ snd = AllpassN.ar(snd, 0.05, [0.05.rand, 0.05.rand], 4) });
	ReplaceOut.ar(0, Limiter.ar(Mix(snd), 0.9))
});

 // RECEIVER 3: PROCESSING ONLY
OSCdef('OSCreceiver',
	{
		arg msg;
		var cutoff;
		var tempo;

		msg.postln;
		cutoff=msg[1];
		tempo = msg[2];

		TempoClock.default.tempo = tempo;
		Pbindef(\wow,\cutoff,cutoff);
	},
	"/note_effect");
)