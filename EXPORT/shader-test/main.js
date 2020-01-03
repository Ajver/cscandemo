
import { loadProgramFromFilepaths } from './base.js'

let canvas = document.getElementById('canvas');

let gl = canvas.getContext('webgl2');
console.log(gl); //console.assert(gl, "no gl");

// firefox: with angle links in about 49789 ms, without 300 ms
// chrome: with angle context lost..., without Fragment shader active uniforms exceed GL_MAX_FRAGMENT_UNIFORM_VECTORS (224)
loadProgramFromFilepaths(gl, './shaders/vs2.glsl', './shaders/fs2.glsl', 'prog2');

//loadProgramFromFilepaths(gl, './shaders/vs_copyshader_chromefail.glsl', './shaders/fs_dummy.glsl', 'prog_copyshader_fail');

//loadProgramFromFilepaths(gl, './shaders/vs2_modded.glsl', './shaders/fs2_modded.glsl', 'prog2');

// fast
//loadProgramFromFilepaths(gl, './shaders/vs2_modded.glsl', './shaders/fs_dummy.glsl', 'prog2_dummyfs');

//loadProgramFromFilepaths(gl, './shaders/vs0.glsl', './shaders/fs_dummy.glsl', 'prog0');

// let vs0 = createShader(gl, gl.VERTEX_SHADER, vsText0, "vs0");
// console.log(vs0);
// let fsDummy = createShader(gl, gl.FRAGMENT_SHADER, fsDummyText, "fsDummy");
// console.log(fsDummy);
// let prog0 = createProgram(gl, vs0, fsDummy, "prog0");
// console.log(prog0);

// let vs1 = createShader(gl, gl.VERTEX_SHADER, vsText1, "vs1");
// let fs1 = createShader(gl, gl.FRAGMENT_SHADER, fsText1, "fs1");
// let prog1 = createProgram(gl, vs1, fs1, "prog1");
// console.log(prog1);

// let vs2 = createShader(gl, gl.VERTEX_SHADER, vsText2, "vs2");
// let fs2 = createShader(gl, gl.FRAGMENT_SHADER, fsText2, "fs2");
// let prog2 = createProgram(gl, vs2, fs2, "prog2");
// console.log(prog2);
