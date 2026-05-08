window.ReactivePanda = {
  mount(selector) {
    const el = typeof selector === 'string' ? document.querySelector(selector) : selector;
    if (!el) return null;

    const svgContent = `
      <svg class="rp-svg" viewBox="0 0 100 110" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Animated Panda Mascot">
        <defs>
          <clipPath id="rp-mouth-clip"><path d="M 40,75 C 40,85 60,85 60,75 Z"/></clipPath>
        </defs>

        <!-- Floaters -->
        <g class="rp-floaters">
          <text class="rp-question" x="50" y="20" text-anchor="middle" font-family="sans-serif" font-weight="900" font-size="28" fill="#1CB0F6">?</text>
          
          <path class="rp-heart rp-heart-1" fill="#FF4B4B" d="M45,25 A5,5 0 0,1 55,25 A5,5 0 0,1 65,25 Q65,32 55,40 Q45,32 45,25 Z"/>
          <path class="rp-heart rp-heart-2" fill="#FF4B4B" d="M25,35 A3,3 0 0,1 31,35 A3,3 0 0,1 37,35 Q37,40 31,45 Q25,40 25,35 Z"/>

          <path class="rp-sparkle rp-sparkle-1" fill="#FFC800" d="M 50,15 L 52,22 L 59,24 L 52,26 L 50,33 L 48,26 L 41,24 L 48,22 Z"/>
          <path class="rp-sparkle rp-sparkle-2" fill="#FFC800" d="M 25,45 L 27,49 L 31,51 L 27,53 L 25,57 L 23,53 L 19,51 L 23,49 Z"/>
          <path class="rp-sparkle rp-sparkle-3" fill="#FFC800" d="M 75,45 L 77,49 L 81,51 L 77,53 L 75,57 L 73,53 L 69,51 L 73,49 Z"/>
          <path class="rp-sparkle rp-sparkle-4" fill="#FFC800" d="M 85,25 L 86,28 L 89,29 L 86,30 L 85,33 L 84,30 L 81,29 L 84,28 Z"/>

          <g class="rp-steam rp-steam-left">
            <circle cx="20" cy="50" r="4" fill="#AFAFAF"/>
            <circle cx="15" cy="45" r="5" fill="#AFAFAF"/>
            <circle cx="12" cy="52" r="3" fill="#AFAFAF"/>
          </g>
          <g class="rp-steam rp-steam-right">
            <circle cx="80" cy="50" r="4" fill="#AFAFAF"/>
            <circle cx="85" cy="45" r="5" fill="#AFAFAF"/>
            <circle cx="88" cy="52" r="3" fill="#AFAFAF"/>
          </g>
        </g>

        <!-- Body Group -->
        <g class="rp-body">
          <!-- Ears -->
          <circle class="rp-ear rp-ear-left" cx="25" cy="45" r="12" fill="#2C2C2C"/>
          <circle class="rp-ear rp-ear-right" cx="75" cy="45" r="12" fill="#2C2C2C"/>
          
          <!-- Head -->
          <ellipse class="panda-head" cx="50" cy="65" rx="35" ry="28" fill="#FFFFFF" stroke="#E5E5E5" stroke-width="2"/>
          
          <!-- Flush -->
          <ellipse class="rp-flush" cx="50" cy="65" rx="30" ry="24" fill="#FFD9D9" opacity="0"/>

          <!-- Blush -->
          <ellipse class="rp-blush rp-blush-left" cx="28" cy="72" rx="4" ry="2.5" fill="#FFB3C1"/>
          <ellipse class="rp-blush rp-blush-right" cx="72" cy="72" rx="4" ry="2.5" fill="#FFB3C1"/>

          <!-- Tear -->
          <path class="rp-tear" fill="#1CB0F6" d="M 32,70 C 32,74 36,74 36,70 C 36,65 34,60 34,60 C 34,60 32,65 32,70 Z"/>

          <!-- Eye Patches -->
          <ellipse class="rp-patch rp-patch-left" cx="35" cy="60" rx="10" ry="14" fill="#2C2C2C" transform="rotate(-20 35 60)"/>
          <ellipse class="rp-patch rp-patch-right" cx="65" cy="60" rx="10" ry="14" fill="#2C2C2C" transform="rotate(20 65 60)"/>

          <!-- Eyes (Whites) -->
          <ellipse class="rp-eye-white rp-eye-white-left" cx="35" cy="60" rx="4.5" ry="5.5" fill="#FFFFFF"/>
          <ellipse class="rp-eye-white rp-eye-white-right" cx="65" cy="60" rx="4.5" ry="5.5" fill="#FFFFFF"/>

          <!-- Pupils -->
          <circle class="rp-pupil rp-pupil-left" cx="35" cy="60" r="2.5" fill="#000000"/>
          <circle class="rp-pupil rp-pupil-right" cx="65" cy="60" r="2.5" fill="#000000"/>

          <!-- Brows -->
          <path class="rp-brow rp-brow-left" d="M 28,48 L 42,52" stroke="#2C2C2C" stroke-width="3" stroke-linecap="round"/>
          <path class="rp-brow rp-brow-right" d="M 72,48 L 58,52" stroke="#2C2C2C" stroke-width="3" stroke-linecap="round"/>

          <!-- Nose -->
          <path d="M 47,70 Q 50,68 53,70 Q 53,73 50,74 Q 47,73 47,70 Z" fill="#2C2C2C"/>

          <!-- Mouths -->
          <path class="rp-mouth-idle" d="M 45,78 Q 50,82 55,78" fill="none" stroke="#2C2C2C" stroke-width="2" stroke-linecap="round"/>
          <path class="rp-mouth-angry" d="M 45,80 Q 50,76 55,80" fill="none" stroke="#2C2C2C" stroke-width="2" stroke-linecap="round"/>
          
          <g class="rp-mouth-happy">
            <path d="M 40,75 C 40,88 60,88 60,75" fill="#4B0014" stroke="#2C2C2C" stroke-width="2"/>
            <ellipse cx="50" cy="84" rx="7" ry="5" fill="#FFB3C1" clip-path="url(#rp-mouth-clip)"/>
          </g>

          <!-- Closed eyes (for blinking) -->
          <path class="rp-eye-closed rp-eye-closed-left" d="M 31,60 Q 35,63 39,60" fill="none" stroke="#2C2C2C" stroke-width="2" stroke-linecap="round"/>
          <path class="rp-eye-closed rp-eye-closed-right" d="M 61,60 Q 65,63 69,60" fill="none" stroke="#2C2C2C" stroke-width="2" stroke-linecap="round"/>

        </g>
      </svg>
    `;
    
    el.innerHTML = svgContent;
    el.classList.add('rp-container', 'state-idle');

    let currentState = 'idle';

    return {
      get state() { return currentState; },
      get el() { return el; },
      react(state) {
        if (!['idle', 'happy', 'angry', 'thinking'].includes(state)) return;
        el.classList.remove('state-idle', 'state-happy', 'state-angry', 'state-thinking');
        // Force reflow to restart CSS animations reliably
        void el.offsetWidth;
        el.classList.add(`state-${state}`);
        currentState = state;
      }
    };
  }
};
