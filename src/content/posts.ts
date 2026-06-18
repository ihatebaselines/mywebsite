export type BlogPost = {
  slug: string;
  title: string;
  date: string;
  category: string;
  excerpt: string;
  shortStory: string;
  cover: string;
  gallery: string[];
  body: string[];
};

export const posts: BlogPost[] = [
  {
    slug: "rise",
    title: "Second Place at RISE Final Round :)",
    date: "2026-06-06",
    category: "Portofolio",
    excerpt: "Second place at the RISE Final Round",
    shortStory:
      "I placed 2nd at the RISE Final Round, an international-style AI competition hosted on Nitro-AI Judge, where I competed as vladandrei.",
    cover: "/images/riselogo.png",
    gallery: ["/images/roaifinalround.png"],
    body: [
      "RISE was one of my strongest competition results so far. After the online qualifier stage, the final round brought together some of the best competitors in a much more intense format, with harder tasks and a lot more pressure.",
      "The final was hosted on Nitro-AI Judge, where I competed using the username vladandrei. The contest followed an AI olympiad-style format, focused on practical problem solving, machine learning intuition, and the ability to build reliable solutions under strict time constraints.",
      "I managed to finish in 2nd place, which made this result especially meaningful for me. It was not just about getting a high score, but about proving that I could stay focused in a final round and compete against strong participants.",
      "This competition helped me become more confident in my AI problem-solving skills. It also motivated me to continue preparing for harder AI competitions, especially ones with tasks inspired by international olympiad formats.",
    ],
  },
  {
    slug: "roainationala",
    title: "ROAI National Stage",
    date: "2026-04-07",
    category: "Portofolio",
    excerpt: "19th place at the ROAI National Stage",
    shortStory:
      "I placed 19th at the ROAI National Stage, one of the main stages of Romania's AI olympiad selection.",
    cover: "/images/portfolio-duck.png",
    gallery: ["/images/nationalaroai.png"],
    body: [
      "ROAI was one of the most important AI competitions I participated in. The National Stage was a serious step up from normal practice rounds, because it gathered qualified students and tested both theoretical understanding and practical AI skills.",
      "I placed 19th in the national phase. For me, this was an important benchmark because it showed where I stood among other students interested in machine learning, data science, algorithms, and AI olympiad-style tasks.",
      "The round required more than just writing code quickly. I had to understand the task, choose the right approach, test ideas carefully, and avoid wasting time on methods that were unlikely to improve the score.",
      "Even though I still saw many things I could improve, this result gave me a lot of motivation. ROAI helped me understand that competitive AI is not only about knowing libraries, but also about strategy, experimentation, clean thinking, and staying calm during difficult tasks.",
    ],
  },
  {
    slug: "roaiprelot",
    title: "ROAI Prelot — Volunteer & Problem Setter",
    date: "2026-04-07",
    category: "Portofolio",
    excerpt:
      "I volunteered and proposed a Reinforcement Learning problem named Funtime Beach, inspired by Gymnasium's Blackjack environment.",
    shortStory:
      "I designed Funtime Beach, a model-based Reinforcement Learning problem inspired by the Blackjack environment from Gymnasium.",
    cover: "/images/portfolio-duck.png",
    gallery: ["/images/prelotproblemamea.png"],
    body: [
      "For ROAI Prelot, I had the chance to contribute from a different perspective: not only as someone who solves problems, but also as a volunteer and problem setter. This helped me understand how much work goes into creating a good contest task.",
      "My proposed problem was called Funtime Beach. It was a Reinforcement Learning task inspired by Gymnasium's Blackjack environment, but reinterpreted in a more original and playful setting. The goal was to keep the decision-making feeling of Blackjack while turning it into a model-based RL problem.",
      "Designing the task was challenging because a good problem needs to be clear, fair, and interesting at the same time. I had to think about how participants would understand the environment, what strategies they could discover, and how the problem statement should guide them without giving away the solution.",
      "This experience helped me improve a lot. It made me better at explaining technical ideas, thinking about edge cases, and understanding competitions from the organizer side. It also made me appreciate problem setters much more, because creating a task can be just as difficult as solving one.",
    ],
  },
  {
    slug: "roaiselection",
    title: "ROAI Selection Camp Qualifier",
    date: "2026-05-18",
    category: "Portofolio",
    excerpt: "33rd place at the ROAI Selection Camp Qualifier",
    shortStory:
      "I placed 33rd at the ROAI Selection Camp Qualifier, the round used to select students for the ROAI camp.",
    cover: "/images/portfolio-duck.png",
    gallery: ["/images/selectielot.png"],
    body: [
      "The ROAI Selection Camp Qualifier was one of the most competitive AI rounds I participated in. It was connected to the selection process for the ROAI camp, so the level was naturally high and the pressure was much stronger than in a regular contest.",
      "I finished in 33rd place. While I would have liked to place higher, this round was still very valuable because it showed me what high-level AI competition tasks look like and what I need to improve for the future.",
      "The contest tested practical skills across machine learning, data processing, and problem-solving. I had to make decisions quickly, experiment with approaches, and manage my time carefully, because in AI competitions even small choices can affect the final score.",
      "This experience pushed me to become more disciplined in how I approach difficult tasks. I learned that strong results come from a combination of preparation, good intuition, clean implementation, and the ability to recover when an idea does not work.",
    ],
  },
  {
    slug: "skillab",
    title: "Skillab — Innovation Challenge",
    date: "2026-05-02",
    category: "Portofolio",
    excerpt: "First place at the Skillab Innovation Challenge",
    shortStory:
      "My team won 1st place at the Skillab Innovation Challenge and received a 1000 euro prize.",
    cover: "/images/skillab-logo-img.jpg",
    gallery: ["/images/angelu.png"],
    body: [
      "Skillab Innovation Challenge was a different kind of competition for me because it combined technology, research, teamwork, and product thinking. Instead of only solving a predefined programming task, we had to think about a real-world problem and build a strong idea around it.",
      "The challenge was connected to skills, jobs, labour market analytics, and the way AI can help understand the gap between what people know and what companies need. This made the event feel very practical, because the topic was not just technical, but also connected to education and the future of work.",
      "Together with my team, I won 1st place and received a 1000 euro prize. The result was really exciting because it showed that our idea was not only technically interesting, but also convincing from an innovation and impact perspective.",
      "This competition helped me improve how I present ideas, how I work in a team, and how I connect AI with real problems. It also gave me more confidence in hackathons and innovation challenges where communication and creativity matter just as much as coding.",
    ],
  },
  {
    slug: "nitronlp",
    title: "NitroNLP Hackathon",
    date: "2026-04-25",
    category: "Portofolio",
    excerpt: "3rd place at Nitro NLP Hackathon 5th Edition",
    shortStory:
      "My team PretrainedLanguageModel placed 3rd at the Nitro NLP Hackathon 5th Edition.",
    cover: "/images/portfolio-duck.png",
    gallery: ["/images/pretrainedlm.png"],
    body: [
      "NitroNLP Hackathon was one of the most fun AI competitions I joined because it focused on Natural Language Processing, a field that combines machine learning, language, data, and experimentation.",
      "I participated with my team, PretrainedLanguageModel, and we competed on Nitro-AI Judge. My username on the platform was vladandrei. The hackathon format made everything more intense because we had to move fast, test ideas, and improve our solution under time pressure.",
      "We placed 3rd, which was a great result for the team. During the competition, teamwork mattered a lot: we had to split responsibilities, compare approaches, and decide quickly which experiments were worth keeping.",
      "This hackathon helped me understand NLP better in a practical way. It was not only about knowing models or libraries, but about building a full solution, evaluating it, improving it, and communicating efficiently with the team.",
    ],
  },
  {
    slug: "esc",
    title: "European Statistics Competition",
    date: "2026-03-21",
    category: "Portofolio",
    excerpt:
      "European Statistics Competition, the official Statistics Olympiad of Romania",
    shortStory:
      "My team society placed 164th in the European Statistics Competition.",
    cover: "/images/esc.png",
    gallery: ["/images/escplace.png"],
    body: [
      "The European Statistics Competition was a different experience from my usual AI and programming contests. It focused more on statistics, data interpretation, official data sources, and explaining conclusions clearly.",
      "I participated with my team, society, and we placed 164th. Even though this was not a top placement, the competition was valuable because it helped me practice a different kind of thinking: less about code, more about understanding data and communicating insights.",
      "The tasks required attention to detail and the ability to interpret information correctly. In statistics, it is not enough to get a number; you also need to explain what that number means and why it matters.",
      "ESC helped me become more comfortable with data analysis, teamwork, and evidence-based reasoning. It also connected well with my interest in AI, because good AI work depends a lot on understanding data properly.",
    ],
  },
  {
    slug: "ccc",
    title: "CCC School & Data/AI :)",
    date: "2026-03-21",
    category: "Portofolio",
    excerpt: "Place School: 4th, Place Data/AI: 12th",
    shortStory:
      "I competed in CCC using the username vladddddddd and placed 4th in School and 12th in Data/AI.",
    cover: "/images/ccc.png",
    gallery: ["/images/ccc2.png"],
    body: [
      "Cloudflight Coding Contest was a very interesting competition because it mixed fast problem solving with a level-based format. Instead of solving completely separate tasks, the contest challenged participants to progress through increasingly difficult levels.",
      "I competed using the username vladddddddd. I placed 4th in the School category and 12th in the Data/AI category, which made this one of my strongest multi-category competition results.",
      "The School category tested classic programming and algorithmic thinking, while the Data/AI category required a different mindset: working with data, models, patterns, and practical experimentation.",
      "What I liked most about CCC was the way it rewarded both speed and persistence. Each level became harder, so the challenge was not just to solve problems, but to keep improving the solution until it passed more difficult cases.",
      "This result showed me that I can perform well across different types of technical competitions, from algorithms to AI and data-oriented tasks. It also motivated me to keep training in both competitive programming and applied machine learning.",
    ],
  },
];

export function getPost(slug: string) {
  return posts.find((post) => post.slug === slug);
}

export function getSortedPosts() {
  return [...posts].sort(
    (first, second) =>
      new Date(second.date).getTime() - new Date(first.date).getTime(),
  );
}
