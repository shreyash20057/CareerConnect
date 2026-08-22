/**
 * CareerConnect — Firestore Seed Script
 * Run: node scripts/seed_firestore.js
 *
 * Prerequisites:
 *   npm install firebase-admin
 *   Download serviceAccountKey.json from Firebase Console →
 *   Project Settings → Service accounts → Generate new private key
 *   Place serviceAccountKey.json in the scripts/ folder
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ── Helpers ───────────────────────────────────────────────────────────────

const now = new Date();
const addDays = (d, n) => {
  const r = new Date(d);
  r.setDate(r.getDate() + n);
  return r;
};
const subDays = (d, n) => addDays(d, -n);

// ── Companies ─────────────────────────────────────────────────────────────

const companies = [
  {
    id: 'c1',
    name: 'TechCorp India',
    description: 'Building next-generation software products',
    industry: 'Software / Technology',
    website: 'https://techcorp.in',
    location: 'Bangalore, Karnataka',
    about:
      'TechCorp India is a fast-growing technology company building enterprise and consumer software products. Founded in 2015, we have grown to 500+ employees across 3 offices. We believe in building products that make a real difference in people\'s lives.',
    employeeCount: 500,
    foundedYear: admin.Timestamp.fromDate(
      new Date('2015-01-01')
    ),
  },
  {
    id: 'c2',
    name: 'StartupHub',
    description: 'Powering the next generation of startups',
    industry: 'SaaS / Cloud',
    website: 'https://startuphub.io',
    location: 'Hyderabad, Telangana',
    about:
      'StartupHub provides cloud infrastructure and developer tools for high-growth startups. We obsess over developer experience and reliability. Our platform powers over 10,000 applications globally.',
    employeeCount: 120,
    foundedYear: admin.Timestamp.fromDate(
      new Date('2019-01-01')
    ),
  },
  {
    id: 'c3',
    name: 'Analytics Pro',
    description: 'Data intelligence for modern businesses',
    industry: 'Data Science / AI',
    website: 'https://analyticspro.ai',
    location: 'Mumbai, Maharashtra',
    about:
      'Analytics Pro builds AI-powered analytics solutions for enterprise clients. Our ML platform processes billions of data points daily, helping businesses make smarter decisions faster.',
    employeeCount: 80,
    foundedYear: admin.Timestamp.fromDate(
      new Date('2020-01-01')
    ),
  },
  {
    id: 'c4',
    name: 'FinEdge',
    description: 'Modern fintech for India',
    industry: 'FinTech',
    website: 'https://finedge.in',
    location: 'Pune, Maharashtra',
    about:
      'FinEdge is a leading fintech startup democratizing financial services for millions of Indians through technology.',
    employeeCount: 200,
    foundedYear: admin.Timestamp.fromDate(
      new Date('2018-01-01')
    ),
  },
];

// ── Jobs & Internships ─────────────────────────────────────────────────────

const opportunities = [
  // ── JOBS ──────────────────────────────────────────────────────────────
  {
    id: 'j1',
    title: 'Flutter Developer',
    companyId: 'c1',
    companyName: 'TechCorp India',
    location: 'Bangalore, Karnataka',
    workMode: 'hybrid',
    type: 'job',
    salary: '₹6–10 LPA',
    requiredSkills: ['Flutter', 'Dart', 'Firebase', 'REST API', 'Git'],
    eligibility: ['B.Tech / B.E.', 'Any branch', 'CGPA ≥ 6.5'],
    shortDescription:
      'Build world-class Flutter apps for millions of users.',
    fullDescription:
      'We are looking for a skilled Flutter developer to join our growing mobile team. You will work on consumer-facing applications used by millions of users daily, collaborating closely with product and design teams to deliver outstanding experiences.',
    responsibilities: [
      'Build and maintain cross-platform Flutter applications',
      'Integrate REST APIs and Firebase services',
      'Collaborate with UI/UX designers and backend engineers',
      'Write unit and widget tests for reliability',
      'Participate in code reviews and sprint planning',
    ],
    experience: '0–2 years',
    education: 'B.Tech / B.E.',
    deadline: admin.Timestamp.fromDate(addDays(now, 30)),
    isActive: true,
    category: 'Mobile Development',
    postedAt: admin.Timestamp.fromDate(subDays(now, 3)),
  },
  {
    id: 'j2',
    title: 'Backend Engineer',
    companyId: 'c2',
    companyName: 'StartupHub',
    location: 'Hyderabad, Telangana',
    workMode: 'remote',
    type: 'job',
    salary: '₹8–14 LPA',
    requiredSkills: [
      'Node.js', 'MongoDB', 'AWS', 'Docker', 'REST API',
    ],
    eligibility: ['B.Tech / B.E.', 'CS / IT preferred'],
    shortDescription:
      'Build scalable backend systems for our growing platform.',
    fullDescription:
      'We need a backend engineer to design and implement robust APIs, microservices, and data pipelines for our rapidly scaling platform serving thousands of startups.',
    responsibilities: [
      'Design and implement scalable REST APIs',
      'Optimise MongoDB queries and schemas',
      'Deploy and manage services on AWS',
      'Write thorough integration tests',
      'Monitor and improve system performance',
    ],
    experience: '1–3 years',
    education: 'B.Tech / B.E.',
    deadline: admin.Timestamp.fromDate(addDays(now, 20)),
    isActive: true,
    category: 'Backend',
    postedAt: admin.Timestamp.fromDate(subDays(now, 1)),
  },
  {
    id: 'j3',
    title: 'Data Scientist',
    companyId: 'c3',
    companyName: 'Analytics Pro',
    location: 'Mumbai, Maharashtra',
    workMode: 'onsite',
    type: 'job',
    salary: '₹10–18 LPA',
    requiredSkills: [
      'Python', 'Machine Learning', 'SQL', 'TensorFlow', 'Pandas',
    ],
    eligibility: ['B.Tech / M.Tech', 'CS / IT / Statistics'],
    shortDescription:
      'Drive data-driven decisions with production ML models.',
    fullDescription:
      'Join our data science team to build predictive models, extract business insights, and create intelligent features for our enterprise analytics platform.',
    responsibilities: [
      'Build and deploy ML models to production',
      'Analyse large-scale datasets and extract insights',
      'Create dashboards and data visualisations',
      'Collaborate with engineering and product teams',
      'Document models and methodologies',
    ],
    experience: '0–2 years',
    education: 'B.Tech / M.Tech',
    deadline: admin.Timestamp.fromDate(addDays(now, 15)),
    isActive: true,
    category: 'Data Science',
    postedAt: admin.Timestamp.fromDate(subDays(now, 5)),
  },
  {
    id: 'j4',
    title: 'DevOps Engineer',
    companyId: 'c2',
    companyName: 'StartupHub',
    location: 'Remote',
    workMode: 'remote',
    type: 'job',
    salary: '₹9–15 LPA',
    requiredSkills: [
      'Docker', 'Kubernetes', 'CI/CD', 'AWS', 'Linux', 'Terraform',
    ],
    eligibility: ['B.Tech / B.E.', 'Any branch'],
    shortDescription:
      'Own our cloud infrastructure and deployment pipelines.',
    fullDescription:
      'We are looking for a DevOps engineer to own our infrastructure, streamline deployments, and ensure high availability and security across all our services.',
    responsibilities: [
      'Build and maintain CI/CD pipelines using GitHub Actions',
      'Manage Kubernetes clusters on AWS EKS',
      'Monitor infrastructure and respond to incidents',
      'Automate operational tasks with scripts',
      'Improve security posture across services',
    ],
    experience: '1–3 years',
    education: 'B.Tech / B.E.',
    deadline: admin.Timestamp.fromDate(addDays(now, 18)),
    isActive: true,
    category: 'DevOps',
    postedAt: admin.Timestamp.fromDate(subDays(now, 2)),
  },
  {
    id: 'j5',
    title: 'React Frontend Developer',
    companyId: 'c4',
    companyName: 'FinEdge',
    location: 'Pune, Maharashtra',
    workMode: 'hybrid',
    type: 'job',
    salary: '₹7–12 LPA',
    requiredSkills: [
      'React', 'TypeScript', 'CSS', 'REST API', 'Git',
    ],
    eligibility: ['B.Tech / B.E.', 'CS / IT / MCA'],
    shortDescription:
      'Build fintech dashboards used by millions of Indians.',
    fullDescription:
      'Join our frontend team to build beautiful, performant web experiences for our fintech platform. You will own end-to-end features from design handoff to production.',
    responsibilities: [
      'Build React components from Figma designs',
      'Integrate financial data APIs',
      'Optimise performance and accessibility',
      'Write component tests with Jest',
      'Mentor junior engineers',
    ],
    experience: '1–2 years',
    education: 'B.Tech / B.E.',
    deadline: admin.Timestamp.fromDate(addDays(now, 25)),
    isActive: true,
    category: 'Web Development',
    postedAt: admin.Timestamp.fromDate(subDays(now, 4)),
  },

  // ── INTERNSHIPS ────────────────────────────────────────────────────────
  {
    id: 'i1',
    title: 'React Developer Intern',
    companyId: 'c1',
    companyName: 'TechCorp India',
    location: 'Bangalore, Karnataka',
    workMode: 'hybrid',
    type: 'internship',
    stipend: '₹15,000/month',
    requiredSkills: ['React', 'JavaScript', 'HTML', 'CSS', 'Git'],
    eligibility: [
      'Any graduation',
      'CS / IT preferred',
      'Pre-final or final year',
    ],
    shortDescription:
      'Build real-world React features used by actual users.',
    fullDescription:
      'As a React intern, you will work directly on our production web application, implementing new features and fixing bugs alongside senior engineers.',
    responsibilities: [
      'Build React components from Figma designs',
      'Integrate REST APIs',
      'Write unit tests for your components',
      'Participate in daily standups',
      'Learn from code reviews',
    ],
    experience: 'Fresher',
    education: 'Any graduation',
    deadline: admin.Timestamp.fromDate(addDays(now, 10)),
    isActive: true,
    category: 'Web Development',
    postedAt: admin.Timestamp.fromDate(subDays(now, 2)),
  },
  {
    id: 'i2',
    title: 'ML Research Intern',
    companyId: 'c3',
    companyName: 'Analytics Pro',
    location: 'Remote',
    workMode: 'remote',
    type: 'internship',
    stipend: '₹20,000/month',
    requiredSkills: [
      'Python', 'NumPy', 'Pandas', 'scikit-learn', 'Jupyter',
    ],
    eligibility: ['B.Tech / M.Tech', 'CS / IT / Statistics'],
    shortDescription:
      'Research and prototype ML algorithms with our science team.',
    fullDescription:
      'Work with our research team on novel machine learning problems, implementing recent papers and evaluating results on real datasets.',
    responsibilities: [
      'Implement and evaluate ML algorithms',
      'Run experiments on large datasets',
      'Write internal research reports',
      'Present findings to the team weekly',
    ],
    experience: 'Fresher',
    education: 'B.Tech / M.Tech',
    deadline: admin.Timestamp.fromDate(addDays(now, 25)),
    isActive: true,
    category: 'Data Science',
    postedAt: admin.Timestamp.fromDate(subDays(now, 4)),
  },
  {
    id: 'i3',
    title: 'Cloud Engineering Intern',
    companyId: 'c2',
    companyName: 'StartupHub',
    location: 'Hyderabad, Telangana',
    workMode: 'hybrid',
    type: 'internship',
    stipend: '₹18,000/month',
    requiredSkills: ['AWS', 'Linux', 'Python', 'Git', 'Bash'],
    eligibility: ['B.Tech / B.E.', 'Any branch'],
    shortDescription:
      'Get hands-on with real cloud infrastructure.',
    fullDescription:
      'Learn and contribute to our cloud infrastructure. You will work with AWS services, automate tasks, and support the DevOps team on real production systems.',
    responsibilities: [
      'Set up and configure AWS services',
      'Write automation scripts in Python and Bash',
      'Monitor infrastructure dashboards',
      'Document cloud procedures',
    ],
    experience: 'Fresher',
    education: 'B.Tech / B.E.',
    deadline: admin.Timestamp.fromDate(addDays(now, 12)),
    isActive: true,
    category: 'Cloud',
    postedAt: admin.Timestamp.fromDate(subDays(now, 6)),
  },
  {
    id: 'i4',
    title: 'FinTech Product Intern',
    companyId: 'c4',
    companyName: 'FinEdge',
    location: 'Pune, Maharashtra',
    workMode: 'onsite',
    type: 'internship',
    stipend: '₹12,000/month',
    requiredSkills: [
      'Excel', 'SQL', 'Product thinking', 'Communication',
    ],
    eligibility: ['Any graduation', 'MBA / B.Tech / BBA'],
    shortDescription: 'Shape fintech products used by millions.',
    fullDescription:
      'Join our product team to research user needs, define requirements, and work closely with engineering and design to build fintech products that matter.',
    responsibilities: [
      'Conduct user interviews and research',
      'Write product requirements documents',
      'Analyse product metrics with SQL',
      'Work with design and engineering teams',
    ],
    experience: 'Fresher',
    education: 'Any graduation',
    deadline: admin.Timestamp.fromDate(addDays(now, 8)),
    isActive: true,
    category: 'Product',
    postedAt: admin.Timestamp.fromDate(subDays(now, 3)),
  },
];

// ── Seed ──────────────────────────────────────────────────────────────────

async function seed() {
  console.log('🌱 Seeding Firestore...\n');

  // Companies
  console.log('Adding companies...');
  const companyBatch = db.batch();
  for (const company of companies) {
    const { id, ...data } = company;
    companyBatch.set(
      db.collection('companies').doc(id),
      data
    );
  }
  await companyBatch.commit();
  console.log(`  ✓ ${companies.length} companies added`);

  // Jobs & Internships
  console.log('Adding opportunities...');
  const jobBatch = db.batch();
  for (const job of opportunities) {
    const { id, ...data } = job;
    jobBatch.set(db.collection('jobs').doc(id), data);
  }
  await jobBatch.commit();
  console.log(
    `  ✓ ${opportunities.length} opportunities added`
  );

  console.log('\n✅ Seeding complete!');
  process.exit(0);
}

seed().catch((err) => {
  console.error('❌ Seeding failed:', err);
  process.exit(1);
});