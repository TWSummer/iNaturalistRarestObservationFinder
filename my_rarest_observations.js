function submitForm(e) {
  e.preventDefault();
  const username = document.getElementById('username').value;

  const observations = fetchObservations(username)
}

function fetchObservations(username) {
  determineTotalObservations(username)
    .then((total_observations) => console.log(total_observations))
}

async function determineTotalObservations(username) {
  const response = await fetch(`https://api.inaturalist.org/v1/observations?user_login=${username}&page=1&per_page=1&order=desc&order_by=created_at`)
  return response.json();
}

document.getElementById('submit_button').addEventListener('click', submitForm);
