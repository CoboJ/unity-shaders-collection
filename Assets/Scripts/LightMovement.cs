using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightMovement : MonoBehaviour
{
    [SerializeField] Transform lightTransform = null;
    [SerializeField] Transform cameraTransform = null;
    [SerializeField] Transform lookTarget = null;
    [SerializeField] float cameraRotationSpeed = 1;
    [SerializeField] float lightRotationSpeed = 1;
    
    [SerializeField, Range(-10, 10)] float radius = 1;
    
    private void Start() {
        StartCoroutine(Rotation());
    }

    IEnumerator Rotation() {
        while (true)
        {
            lightTransform.Rotate(Vector3.up * 180 * lightRotationSpeed * Time.deltaTime, Space.World);
            float angle = Mathf.PI * cameraRotationSpeed * Time.fixedTime;
            float xPos = Mathf.Cos(angle) * radius;
            float zPos = Mathf.Sin(angle) * radius;
            cameraTransform.position = new Vector3(xPos, cameraTransform.position.y, zPos);
            cameraTransform.LookAt(lookTarget);
            yield return null;
        }
    }
}
