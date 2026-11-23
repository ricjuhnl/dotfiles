// El borde de la ventana con foco y su sombra, de morgan para Umbriel. Lo escribe morgan
// (umbriel_cfg.rs) con las constantes de la sombra elegida en el menú: no editar a mano.
//
// Umbriel pinta el borde con colores lisos; esto lo pinta en degradé de accent_primary a
// accent_secondary, con la fórmula de Hyprland 0.57.1 para un gradiente de dos colores
// (src/render/shaders/glsl/gradient.glsl): progreso y·sin(a) + x·(1 − sin(a)) sobre la caja,
// en coordenadas normalizadas, con la interpolación en OkLab. La forma del anillo (ancho,
// radio, antialias) sale de la alfa del anillo nativo.
//
// Alrededor va la sombra, con la fórmula de Hyprland (shadow.glsl): opacidad
// ((RANGO − d) / RANGO)^POTENCIA, con d la distancia al borde exterior del anillo y el degradé
// calculado sobre la caja de la sombra. El rectángulo dibujado es el anillo más `padding`
// (= RANGO) por lado, así que el grosor del borde sale de dónde empieza el hueco.
//   GLOW = 1: el degradé del borde con alfa ALFA_GLOW (el 30 % de templates/hyprland.lua).
//   GLOW = 0: sombra negra con alfa ALFA_NEGRA (Roberto, 2026-11-07: opaca pesaba un poco;
//   las sombras de las superficies de morgan no cambian).

const float ANGULO = 0.785398; // 45°
const float RANGO = 6.0;
const float POTENCIA = 2.0;
const float GLOW = 0.0;
const float ALFA_GLOW = 0.302; // 0x4d / 255
const float ALFA_NEGRA = 0.8; // 0xcc / 255

vec3 a_lineal(vec3 c) {
  return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(0.04045, c));
}

vec3 a_srgb(vec3 c) {
  c = max(c, vec3(0.0));
  return mix(c * 12.92, 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055, step(0.0031308, c));
}

vec3 a_oklab(vec3 c) {
  c = a_lineal(c);
  vec3 lms = vec3(
    0.4122214708 * c.r + 0.5363325363 * c.g + 0.0514459929 * c.b,
    0.2119034982 * c.r + 0.6806995451 * c.g + 0.1073969566 * c.b,
    0.0883024619 * c.r + 0.2817188376 * c.g + 0.6299787005 * c.b);
  lms = pow(lms, vec3(1.0 / 3.0));
  return vec3(
    0.2104542553 * lms.x + 0.7936177850 * lms.y - 0.0040720468 * lms.z,
    1.9779984951 * lms.x - 2.4285922050 * lms.y + 0.4505937099 * lms.z,
    0.0259040371 * lms.x + 0.7827717662 * lms.y - 0.8086757660 * lms.z);
}

vec3 desde_oklab(vec3 lab) {
  vec3 lms = vec3(
    lab.x + 0.3963377774 * lab.y + 0.2158037573 * lab.z,
    lab.x - 0.1055613458 * lab.y - 0.0638541728 * lab.z,
    lab.x - 0.0894841775 * lab.y - 1.2914855480 * lab.z);
  lms = lms * lms * lms;
  return a_srgb(vec3(
     4.0767416621 * lms.x - 3.3077115913 * lms.y + 0.2309699292 * lms.z,
    -1.2684380046 * lms.x + 2.6097574011 * lms.y - 0.3413193965 * lms.z,
    -0.0041960863 * lms.x - 0.7034186147 * lms.y + 1.7076147010 * lms.z));
}

vec3 degrade(vec2 caja) {
  // Paleta: 0.0 es accent_primary y 0.25 accent_secondary (cuatro colores en [0, 1)).
  vec3 desde = a_oklab(umbriel_palette_at(0.0).rgb);
  vec3 hasta = a_oklab(umbriel_palette_at(0.25).rgb);
  float s = sin(ANGULO);
  float progreso = clamp(caja.y * s + caja.x * (1.0 - s), 0.0, 1.0);
  return desde_oklab(mix(desde, hasta, progreso));
}

vec4 border(vec2 uv) {
  // Caja del anillo en uv: lo dibujado menos RANGO píxeles por lado.
  vec2 margen = vec2(RANGO) / umbriel_size;
  vec2 tamano = vec2(1.0) - 2.0 * margen;
  float anillo = umbriel_sample(uv).a;
  vec4 borde = vec4(degrade((uv - margen) / tamano) * anillo, anillo);

  float grosor = umbriel_border_hole.x * umbriel_size.x - RANGO;
  float d = max(umbriel_border_distance(uv) - grosor, 0.0);
  float caida = d >= RANGO ? 0.0 : pow((RANGO - d) / RANGO, POTENCIA);
  vec4 color = GLOW > 0.5 ? vec4(degrade(uv), ALFA_GLOW) : vec4(0.0, 0.0, 0.0, ALFA_NEGRA);
  float a = color.a * caida;
  return borde + vec4(color.rgb * a, a) * (1.0 - borde.a);
}
