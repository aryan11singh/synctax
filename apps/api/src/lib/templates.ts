import type { RoomTemplate } from '@synctax/db'

const TEMPLATE_FILES: Record<RoomTemplate, Array<{ path: string; content: string }>> = {
  PYTHON: [{ path: 'main.py', content: 'print("Hello, Synctax!")\n' }],
  CPP: [
    {
      path: 'main.cpp',
      content:
        '#include <iostream>\n\nint main() {\n    std::cout << "Hello, Synctax!" << std::endl;\n    return 0;\n}\n',
    },
  ],
  JAVA: [
    {
      path: 'Main.java',
      content:
        'public class Main {\n    public static void main(String[] args) {\n        System.out.println("Hello, Synctax!");\n    }\n}\n',
    },
  ],
  JAVASCRIPT: [{ path: 'main.js', content: 'console.log("Hello, Synctax!")\n' }],
  BLANK: [],
}

export const templateFiles = (template: RoomTemplate): Array<{ path: string; content: string }> =>
  TEMPLATE_FILES[template]
